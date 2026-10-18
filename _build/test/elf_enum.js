// Regression test for https://github.com/kaitai-io/kaitai_struct_formats/issues/764.
// Dependencies: kaitai-struct-compiler@0.11.0, kaitai-struct@0.11.0, yaml@2.
// Run: node _build/test/elf_enum.js [path/to/elf.ksy] [fixture-output-directory]
// Dependencies may be installed outside this repository and supplied via NODE_PATH.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Module = require('node:module');
const compiler = require('kaitai-struct-compiler');
const YAML = require('yaml');
const KaitaiStream = require('kaitai-struct/KaitaiStream');

// Construct complete, minimal ELF files independently of the format description.
function fixture(bits, endian, machine, abi, shType, phType, payload) {
  const ehSize = bits === 32 ? 52 : 64;
  const phSize = bits === 32 ? 32 : 56;
  const shSize = bits === 32 ? 40 : 64;
  const bodyOffset = ehSize + phSize + 2 * shSize;
  const b = Buffer.alloc(bodyOffset + payload.length);
  b.set([0x7f, 0x45, 0x4c, 0x46, bits === 32 ? 1 : 2, endian, 1, abi]);
  let offset = 16;
  function put(value, size) {
    if (size === 8) b[endian === 1 ? 'writeBigUInt64LE' : 'writeBigUInt64BE'](BigInt(value), offset);
    else b[endian === 1 ? 'writeUIntLE' : 'writeUIntBE'](value, offset, size);
    offset += size;
  }
  const word = bits / 8;
  put(1, 2); put(machine, 2); put(1, 4); // ET_REL, e_machine, EV_CURRENT
  put(0, word); put(ehSize, word); put(ehSize + phSize, word); put(0, 4);
  put(ehSize, 2); put(phSize, 2); put(1, 2); put(shSize, 2); put(2, 2); put(0, 2);
  put(phType, 4);
  if (bits === 64) put(0, 4);
  put(bodyOffset, word); put(0, word); put(0, word);
  put(payload.length, word); put(payload.length, word);
  if (bits === 32) put(0, 4);
  put(1, word);
  offset += shSize; // Section header zero is the mandatory SHT_NULL entry.
  put(0, 4); put(shType, 4); put(0, word); put(0, word);
  put(bodyOffset, word); put(payload.length, word);
  put(0, 4); put(0, 4); put(1, word); put(0, word);
  assert.equal(offset, bodyOffset);
  payload.copy(b, bodyOffset);
  return b;
}

async function main() {
  const source = process.argv[2] || path.join(__dirname, '../../executable/elf.ksy');
  const fixtureDir = process.argv[3];
  const spec = YAML.parse(fs.readFileSync(source, 'utf8'));
  const files = await compiler.compile('javascript', spec, null, false);
  const generated = new Module(path.join(__dirname, 'Elf.js'), module);
  generated.filename = generated.id;
  generated.paths = module.paths;
  generated._compile(files['Elf.js'], generated.filename);
  const { Elf } = generated.exports;
  const shViews = ['typeArm', 'typeAarch64', 'typeX8664', 'typeSparc'];
  const phViews = ['typeArm', 'typeAarch64', 'typeRiscv'];
  let cases = 0;
  const manifest = [];

  function check(bits, endian, machine, abi, shType, phType, expectedSh, expectedPh,
                 payload = Buffer.from('test\0')) {
    const bytes = fixture(bits, endian, machine, abi, shType, phType, payload);
    const elf = new Elf(new KaitaiStream(bytes));
    const sh = elf.header.sectionHeaders[1];
    const ph = elf.header.programHeaders[0];
    if (shType >= 0x70000000 && shType <= 0x7fffffff) assert.equal(Elf.ShType[sh.type], undefined);
    if (phType >= 0x70000000 && phType <= 0x7fffffff) assert.equal(Elf.PhType[ph.type], undefined);
    assert.equal(sh.typeRaw, shType);
    assert.equal(ph.typeRaw, phType);
    assert.equal(sh.type, shType);
    assert.equal(ph.type, phType);
    for (const view of shViews) assert.equal(sh[view], expectedSh && view === expectedSh[0] ? shType : undefined);
    for (const view of phViews) assert.equal(ph[view], expectedPh && view === expectedPh[0] ? phType : undefined);
    if (expectedSh) assert.equal(Elf[expectedSh[1]][sh[expectedSh[0]]], expectedSh[2] || undefined);
    if (expectedPh) assert.equal(Elf[expectedPh[1]][ph[expectedPh[0]]], expectedPh[2] || undefined);
    // A processor type must never be mislabeled as an unrelated common type.
    if (shType === 3) assert.deepEqual(sh.body.entries, ['test']);
    else if (shType === 0x6fffffff) assert.ok(sh.body instanceof Elf.EndianElf.VersymSection);
    else if (shType === 0x6ffffffd) assert.ok(sh.body instanceof Elf.EndianElf.VerdefSection);
    else if (shType === 0x6ffffffe) assert.ok(sh.body instanceof Elf.EndianElf.VerneedSection);
    else if (shType === 8) assert.equal(sh.body, undefined);
    else assert.deepEqual(Buffer.from(sh.body), payload);
    if (payload.length === 0) assert.equal(ph.body, undefined);
    else if (phType === 3) assert.equal(ph.body.pathName, 'test');
    else assert.deepEqual(Buffer.from(ph.body), payload);
    if (fixtureDir) {
      fs.mkdirSync(fixtureDir, {recursive: true});
      const name = `case-${cases}.elf`;
      fs.writeFileSync(path.join(fixtureDir, name), bytes);
      manifest.push({name, bits, endian, machine, abi, shType, phType, expectedSh, expectedPh});
    }
    cases++;
  }

  for (const bits of [32, 64]) for (const endian of [1, 2]) {
    check(bits, endian, 40, 0, 0x70000001, 0x70000001,
          ['typeArm', 'ShTypeArm', 'EXIDX'], ['typeArm', 'PhTypeArm', 'EXIDX']);
    check(bits, endian, 62, 0, 0x70000001, 0x70000001,
          ['typeX8664', 'ShTypeX8664', 'UNWIND'], null);
    for (const [raw, armName, aarch64Name] of [[3, 'ATTRIBUTES', 'ATTRIBUTES'], [4, 'DEBUGOVERLAY', 'AUTH_RELR']]) {
      check(bits, endian, 40, 0, 0x70000000 + raw, 0x70000000,
            ['typeArm', 'ShTypeArm', armName], ['typeArm', 'PhTypeArm', 'ARCHEXT']);
      check(bits, endian, 183, 0, 0x70000000 + raw, 0x70000000,
            ['typeAarch64', 'ShTypeAarch64', aarch64Name], ['typeAarch64', 'PhTypeAarch64', 'ARCHEXT']);
    }
    for (const [raw, name] of [[2, 'PREEMPTMAP'], [5, 'OVERLAYSECTION']])
      check(bits, endian, 40, 0, 0x70000000 + raw, 0x70000001,
            ['typeArm', 'ShTypeArm', name], ['typeArm', 'PhTypeArm', 'EXIDX']);
    for (const [raw, name] of [[7, 'MEMTAG_GLOBALS_STATIC'], [8, 'MEMTAG_GLOBALS_DYNAMIC']])
      check(bits, endian, 183, 0, 0x70000000 + raw, 0x70000002,
            ['typeAarch64', 'ShTypeAarch64', name], ['typeAarch64', 'PhTypeAarch64', 'MEMTAG_MTE']);
    for (const machine of [2, 18, 43])
      check(bits, endian, machine, 0, 0x70000000, 0x70000000,
            ['typeSparc', 'ShTypeSparc', 'GOTDATA'], null);
    check(bits, endian, 243, 0, 0x70000003, 0x70000003, null,
          ['typeRiscv', 'PhTypeRiscv', 'ATTRIBUTES']);
    for (const raw of [0x70000000, 0x70000006, 0x7fffffff])
      check(bits, endian, 40, 0, raw, 0x7fffffff,
            ['typeArm', 'ShTypeArm', null], ['typeArm', 'PhTypeArm', null]);
    // Unhandled architectures must not acquire ARM, SPARC or x86-64 labels.
    for (const machine of [3, 8, 21, 258])
      for (const raw of [0x70000000, 0x70000001, 0x70000003, 0x7fffffff])
        check(bits, endian, machine, 0, raw, raw, null, null);
    for (const machine of [40, 62, 183]) for (const abi of [0, 3, 6, 9]) {
      check(bits, endian, machine, abi, 3, 3, null, null);
      check(bits, endian, machine, abi, 8, 1, null, null);
      // GNU and LLVM values must not depend on EI_OSABI or e_machine.
      for (const raw of [0x6ffffff6, 0x6fff4c03, 0x6ffffffd, 0x6ffffffe]) {
        const payload = Buffer.alloc(raw === 0x6ffffffd ? 28 : raw === 0x6ffffffe ? 32 : 0);
        if (payload.length) {
          const u2 = endian === 1 ? 'writeUInt16LE' : 'writeUInt16BE';
          const u4 = endian === 1 ? 'writeUInt32LE' : 'writeUInt32BE';
          payload[u2](1, 0); // version
          payload[u2](1, raw === 0x6ffffffd ? 6 : 2); // auxiliary count
          payload[u4](raw === 0x6ffffffd ? 20 : 16, raw === 0x6ffffffd ? 12 : 8);
        }
        check(bits, endian, machine, abi, raw, 0x6474e551, null, null, payload);
        assert.ok(Elf.ShType[raw]);
        assert.equal(Elf.PhType[0x6474e551], 'GNU_STACK');
      }
      const version = Buffer.from(endian === 1 ? [1, 0] : [0, 1]);
      check(bits, endian, machine, abi, 0x6fffffff, 1, null, null, version);
    }
    for (const raw of [0x6fffffff, 0x80000000, 0xffffffff])
      check(bits, endian, 40, 0, raw, raw, null, null, Buffer.alloc(0));
  }
  if (fixtureDir) fs.writeFileSync(path.join(fixtureDir, 'manifest.json'), JSON.stringify(manifest, null, 2));
  console.log(`PASS: ${cases} ELF fixtures (32/64-bit, little/big endian; KSC ${compiler.version})`);
}

main().catch(error => { console.error(error); process.exitCode = 1; });
