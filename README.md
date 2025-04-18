# HMAC-SHA256
HMAC-SHA256 hardware implementation written in Verilog. The SHA256 code is sourced from secworks https://github.com/secworks/sha256

This code was written using the following definition of HMAC https://www.rfc-editor.org/rfc/rfc2104 (see '2. Definition of HMAC'), 
using test vectors from https://www.rfc-editor.org/rfc/rfc4868.

This set of encryption modules, along with an adaptation of AES256, were integrated into a chip used for testing a side-channel attack detection system (with a focus on power-analysis attacks). The project title is “In-sensor data security via advanced algorithm/circuit co-design" at Professor Ningyuan Cao's lab in Notre Dame University. 
