meta:
  id: avantes_roh60
  file-extension: roh
  license: CC0-1.0
  endian: le
doc: |
  Avantes USB spectrometers are supplied with a Windows binary which 
  generates one ROH and one RCM file when the user clicks "Save
  experiment". In the version of 6.0, the ROH file contains a header 
  of 22 four-byte floats, then the spectrum as a float array and a 
  footer of 3 floats. The first and last pixel numbers are specified in the 
  header and determine the (length+1) of the spectral data. In the tested 
  files, the length is (2032-211-1)=1820 pixels, but Kaitai determines this 
  automatically anyway.

  The wavelength calibration is stored as a polynomial with coefficients
  of 'wlintercept', 'wlx1', ... 'wlx4', the argument of which is the
  (pixel number + 1), as found out by comparing with the original 
  Avantes converted data files. There is no intensity calibration saved,
  but it is recommended to do it in your program - the CCD in the spectrometer 
  is so uneven that one should prepare exact pixel-to-pixel calibration curves 
  to get reasonable spectral results.

  The rest of the header floats is not known to the author. Note that the 
  newer version of Avantes software has a different format, see also
  https://kr.mathworks.com/examples/matlab/community/20341-reading-spectra-from-avantes-binary-files-demonstration

  The RCM file contains the user-specified comment, so it may be useful
  for automatic conversion of data. You may wish to divide the spectra by 
  the integration time before comparing them.
  
  Written and tested by Filip Dominec, 2017-2018
seq:
  - id: unknown1
    type: f4
  - id: wlintercept
    type: f4
  - id: wlx1
    type: f4
  - id: wlx2
    type: f4
  - id: wlx3
    type: f4
  - id: wlx4
    type: f4
  - id: unknown2
    type: f4
    repeat: expr
    repeat-expr: 9
  - id: ipixfirst
    type: f4
  - id: ipixlast
    type: f4
  - id: unknown3
    type: f4
    repeat: expr
    repeat-expr: 4
  - id: spectrum
    type: f4
    repeat: expr
    repeat-expr: ipixlast.to_i - ipixfirst.to_i - 1
  - id: integration_ms
    type: f4
  - id: averaging
    type: f4
  - id: pixel_smoothing
    type: f4
