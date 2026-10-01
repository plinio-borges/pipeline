# -*- coding: utf-8 -*-
import base64

# String Base64 fornecida
base64_string = "Q2FydDBlc0AyMDI0"

# Decodificando para bytes
decoded_bytes = base64.b64decode(base64_string)

# Convertendo bytes para string UTF-8
decoded_string = decoded_bytes.decode('utf-8')

print("String decodificada:", decoded_string)
