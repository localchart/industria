#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*-
;; Copyright © 2009 Göran Weinholt <goran@weinholt.se>
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
#!r6rs

(import (weinholt crypto x509)
        (weinholt crypto sha-1)
        (weinholt text base64)
        (srfi :78 lightweight-testing)
        (rnrs))

;; Examples referenced in RFC 5280 at this URL:
;; <http://csrc.nist.gov/groups/ST/crypto_apps_infra/documents/pkixtools/>

(define rfc3280-cert1                   ;DSA
  #vu8(48 130 2 187 48 130 2 123 160 3 2 1 2 2 1 17 48 9 6 7
          42 134 72 206 56 4 3 48 42 49 11 48 9 6 3 85 4 6 19 2
          85 83 49 12 48 10 6 3 85 4 10 19 3 103 111 118 49 13 48
          11 6 3 85 4 11 19 4 78 73 83 84 48 30 23 13 57 55 48 54
          51 48 48 48 48 48 48 48 90 23 13 57 55 49 50 51 49 48
          48 48 48 48 48 90 48 42 49 11 48 9 6 3 85 4 6 19 2 85
          83 49 12 48 10 6 3 85 4 10 19 3 103 111 118 49 13 48 11
          6 3 85 4 11 19 4 78 73 83 84 48 130 1 184 48 130 1 44 6
          7 42 134 72 206 56 4 1 48 130 1 31 2 129 129 0 182 139
          15 148 43 154 206 165 37 198 242 237 252 251 149 50 172
          1 18 51 185 224 28 173 144 155 188 72 84 158 243 148
          119 60 44 113 53 85 230 254 79 34 203 213 216 62 137
          147 51 77 252 189 79 65 100 62 162 152 112 236 49 180
          80 222 235 241 152 40 10 201 62 68 179 253 34 151 150
          131 208 24 163 227 189 53 91 255 238 163 33 114 106 123
          150 218 185 63 30 90 144 175 36 214 32 240 13 33 167
          212 2 185 26 252 172 33 251 158 148 158 75 66 69 158
          106 178 72 99 254 67 2 21 0 178 13 176 177 1 223 12 102
          36 252 19 146 186 85 247 125 87 116 129 229 2 129 129 0
          154 191 70 177 245 63 68 61 201 165 101 251 145 192 142
          71 241 10 195 1 71 194 68 66 54 169 146 129 222 87 197
          224 104 134 88 0 123 31 249 155 119 161 197 16 165 128
          145 120 81 81 60 246 252 252 204 70 198 129 120 146 132
          61 244 147 61 12 56 126 26 91 153 78 171 20 100 246 12
          33 34 78 40 8 156 146 185 102 159 64 232 149 246 213 49
          42 239 57 162 98 199 178 109 158 88 196 58 168 17 129
          132 109 175 248 180 25 180 194 17 174 208 34 59 170 32
          127 238 30 87 24 3 129 133 0 2 129 129 0 181 158 31 73
          4 71 209 219 245 58 221 202 4 117 232 221 117 246 155
          138 177 151 214 89 105 130 211 3 77 253 59 54 95 74 242
          209 78 193 7 245 209 42 211 120 119 99 86 234 150 97 77
          66 11 122 29 251 171 145 164 206 222 239 119 200 229
          239 32 174 166 40 72 175 190 105 195 106 165 48 242 194
          185 217 130 43 125 217 196 132 31 222 13 232 84 215 27
          153 46 179 208 136 246 214 99 155 167 226 14 130 212 59
          138 104 27 6 86 49 89 11 73 235 153 165 213 129 65 123
          201 85 163 50 48 48 48 29 6 3 85 29 14 4 22 4 20 134
          202 165 34 129 98 239 173 10 137 188 173 114 65 44 41
          73 244 134 86 48 15 6 3 85 29 19 1 1 255 4 5 48 3 1 1
          255 48 9 6 7 42 134 72 206 56 4 3 3 47 0 48 44 2 20 67
          27 207 41 37 69 192 78 82 231 125 214 252 177 102 76
          131 207 45 119 2 20 11 91 154 36 17 152 232 243 134 144
          4 246 8 169 225 141 165 204 58 212))

(define rfc3280-cert2                   ;DSA
  #vu8(48 130 2 218 48 130 2 153 160 3 2 1 2 2 1 18 48 9 6 7
          42 134 72 206 56 4 3 48 42 49 11 48 9 6 3 85 4 6 19 2
          85 83 49 12 48 10 6 3 85 4 10 19 3 103 111 118 49 13 48
          11 6 3 85 4 11 19 4 78 73 83 84 48 30 23 13 57 55 48 55
          51 48 48 48 48 48 48 48 90 23 13 57 55 49 50 48 49 48
          48 48 48 48 48 90 48 61 49 11 48 9 6 3 85 4 6 19 2 85
          83 49 12 48 10 6 3 85 4 10 19 3 103 111 118 49 13 48 11
          6 3 85 4 11 19 4 78 73 83 84 49 17 48 15 6 3 85 4 3 19
          8 84 105 109 32 80 111 108 107 48 130 1 183 48 130 1 44
          6 7 42 134 72 206 56 4 1 48 130 1 31 2 129 129 0 182
          139 15 148 43 154 206 165 37 198 242 237 252 251 149 50
          172 1 18 51 185 224 28 173 144 155 188 72 84 158 243
          148 119 60 44 113 53 85 230 254 79 34 203 213 216 62
          137 147 51 77 252 189 79 65 100 62 162 152 112 236 49
          180 80 222 235 241 152 40 10 201 62 68 179 253 34 151
          150 131 208 24 163 227 189 53 91 255 238 163 33 114 106
          123 150 218 185 63 30 90 144 175 36 214 32 240 13 33
          167 212 2 185 26 252 172 33 251 158 148 158 75 66 69
          158 106 178 72 99 254 67 2 21 0 178 13 176 177 1 223 12
          102 36 252 19 146 186 85 247 125 87 116 129 229 2 129
          129 0 154 191 70 177 245 63 68 61 201 165 101 251 145
          192 142 71 241 10 195 1 71 194 68 66 54 169 146 129 222
          87 197 224 104 134 88 0 123 31 249 155 119 161 197 16
          165 128 145 120 81 81 60 246 252 252 204 70 198 129 120
          146 132 61 244 147 61 12 56 126 26 91 153 78 171 20 100
          246 12 33 34 78 40 8 156 146 185 102 159 64 232 149 246
          213 49 42 239 57 162 98 199 178 109 158 88 196 58 168
          17 129 132 109 175 248 180 25 180 194 17 174 208 34 59
          170 32 127 238 30 87 24 3 129 132 0 2 129 128 48 182
          117 247 124 32 49 174 56 187 126 13 43 171 160 156 75
          223 32 213 36 19 60 205 152 229 95 108 183 193 186 74
          186 169 149 128 83 240 13 114 220 51 55 244 1 11 245 4
          31 157 46 31 98 216 132 58 155 37 9 90 45 200 70 142 43
          212 245 13 59 199 45 198 108 185 152 193 37 58 68 78
          142 202 149 97 53 124 206 21 49 92 35 19 30 162 5 209
          122 36 28 203 211 114 9 144 255 155 157 40 192 161 10
          236 70 159 13 184 208 220 208 24 166 43 94 249 143 181
          149 190 163 62 48 60 48 25 6 3 85 29 17 4 18 48 16 129
          14 119 112 111 108 107 64 110 105 115 116 46 103 111
          118 48 31 6 3 85 29 35 4 24 48 22 128 20 134 202 165 34
          129 98 239 173 10 137 188 173 114 65 44 41 73 244 134
          86 48 9 6 7 42 134 72 206 56 4 3 3 48 0 48 45 2 20 54
          151 203 227 180 44 225 187 97 169 211 204 36 204 34 146
          159 244 245 135 2 21 0 171 201 121 175 210 22 28 169
          227 104 169 20 16 180 160 46 255 34 90 115))

(define rfc3280-cert3                   ;RSA
  #vu8(48 130 2 142 48 130 1 247 160 3 2 1 2 2 2 1 0 48 13 6 9
          42 134 72 134 247 13 1 1 5 5 0 48 42 49 11 48 9 6 3 85
          4 6 19 2 85 83 49 12 48 10 6 3 85 4 11 19 3 103 111 118
          49 13 48 11 6 3 85 4 10 19 4 78 73 83 84 48 30 23 13 57
          54 48 53 50 49 48 57 53 56 50 54 90 23 13 57 55 48 53
          50 49 48 57 53 56 50 54 90 48 61 49 11 48 9 6 3 85 4 6
          19 2 85 83 49 12 48 10 6 3 85 4 11 19 3 103 111 118 49
          13 48 11 6 3 85 4 10 19 4 78 73 83 84 49 17 48 15 6 3
          85 4 3 19 8 84 105 109 32 80 111 108 107 48 129 159 48
          13 6 9 42 134 72 134 247 13 1 1 1 5 0 3 129 141 0 48
          129 137 2 129 129 0 225 106 228 3 48 151 2 60 244 16
          243 181 30 77 127 20 123 246 245 208 120 233 164 138
          240 163 117 236 237 182 86 150 127 136 153 133 154 242
          62 104 119 135 235 158 209 159 192 180 23 220 171 137
          35 164 29 126 22 35 76 79 168 77 245 49 184 124 170 227
          26 73 9 244 75 38 219 39 103 48 130 18 1 74 233 26 182
          193 12 83 139 108 252 47 122 67 236 51 54 126 50 178
          123 213 170 207 1 20 198 18 236 19 242 45 20 122 139 33
          88 20 19 76 70 163 154 242 22 149 255 35 2 3 1 0 1 163
          129 175 48 129 172 48 63 6 3 85 29 17 4 56 48 54 134 52
          104 116 116 112 58 47 47 119 119 119 46 105 116 108 46
          110 105 115 116 46 103 111 118 47 100 105 118 56 57 51
          47 115 116 97 102 102 47 112 111 108 107 47 105 110 100
          101 120 46 104 116 109 108 48 31 6 3 85 29 18 4 24 48
          22 134 20 104 116 116 112 58 47 47 119 119 119 46 110
          105 115 116 46 103 111 118 47 48 31 6 3 85 29 35 4 24
          48 22 128 20 8 104 175 133 51 200 57 74 122 248 130 147
          142 112 106 74 32 132 44 50 48 23 6 3 85 29 32 4 16 48
          14 48 12 6 10 96 134 72 1 101 3 2 1 48 9 48 14 6 3 85
          29 15 1 1 255 4 4 3 2 7 128 48 13 6 9 42 134 72 134 247
          13 1 1 5 5 0 3 129 129 0 142 142 54 86 120 139 191 161
          57 117 23 46 227 16 220 131 43 104 52 82 28 246 108 29
          82 94 84 32 16 94 76 169 64 249 75 114 158 130 185 97
          220 235 50 165 189 177 177 72 249 155 1 187 235 175 155
          131 246 82 140 176 109 124 208 154 57 84 62 109 32 111
          205 208 222 190 39 95 32 79 182 171 13 245 183 225 186
          180 223 223 61 212 246 237 1 251 110 203 152 89 172 65
          251 72 156 31 246 91 70 224 41 226 118 236 196 58 10
          252 146 197 192 210 169 201 211 41 82 135 101 51))

(define rfc3280bis-cert1                ;RSA
  #vu8(48 130 2 62 48 130 1 167 160 3 2 1 2 2 1 17 48 13 6 9
          42 134 72 134 247 13 1 1 5 5 0 48 67 49 19 48 17 6 10 9
          146 38 137 147 242 44 100 1 25 22 3 99 111 109 49 23 48
          21 6 10 9 146 38 137 147 242 44 100 1 25 22 7 101 120
          97 109 112 108 101 49 19 48 17 6 3 85 4 3 19 10 69 120
          97 109 112 108 101 32 67 65 48 30 23 13 48 52 48 52 51
          48 49 52 50 53 51 52 90 23 13 48 53 48 52 51 48 49 52
          50 53 51 52 90 48 67 49 19 48 17 6 10 9 146 38 137 147
          242 44 100 1 25 22 3 99 111 109 49 23 48 21 6 10 9 146
          38 137 147 242 44 100 1 25 22 7 101 120 97 109 112 108
          101 49 19 48 17 6 3 85 4 3 19 10 69 120 97 109 112 108
          101 32 67 65 48 129 159 48 13 6 9 42 134 72 134 247 13
          1 1 1 5 0 3 129 141 0 48 129 137 2 129 129 0 194 215
          151 109 40 112 170 91 207 35 46 128 112 57 238 219 111
          213 45 213 106 79 122 52 45 249 34 114 71 112 29 239
          128 233 202 48 140 0 196 154 110 91 69 180 110 165 230
          108 148 13 250 145 233 64 252 37 157 199 183 104 25 86
          143 17 112 106 215 241 201 17 79 58 126 63 153 141 110
          118 165 116 95 94 164 85 83 229 199 104 54 83 199 29 59
          18 166 133 254 189 110 161 202 223 53 80 172 8 215 185
          180 126 92 254 226 163 44 209 35 132 170 152 192 155
          102 24 154 104 71 233 2 3 1 0 1 163 66 48 64 48 29 6 3
          85 29 14 4 22 4 20 8 104 175 133 51 200 57 74 122 248
          130 147 142 112 106 74 32 132 44 50 48 14 6 3 85 29 15
          1 1 255 4 4 3 2 1 6 48 15 6 3 85 29 19 1 1 255 4 5 48 3
          1 1 255 48 13 6 9 42 134 72 134 247 13 1 1 5 5 0 3 129
          129 0 108 248 2 116 166 97 226 100 4 166 84 12 108 114
          19 173 60 71 251 246 101 19 169 133 144 51 234 118 163
          38 217 252 209 14 21 95 40 183 239 147 191 60 243 226
          62 124 185 82 252 22 110 41 170 225 244 122 111 213 127
          239 179 149 202 243 102 136 131 78 161 53 69 132 203
          188 155 184 200 173 197 94 70 217 11 14 141 128 225 51
          43 220 190 43 146 126 74 67 169 106 239 138 99 97 179
          110 71 56 190 232 13 163 103 93 243 250 145 129 60 146
          187 197 95 37 37 235 124 231 216 161))

(define rfc3280bis-cert2                ;RSA
  #vu8(48 130 2 113 48 130 1 218 160 3 2 1 2 2 1 18 48 13 6 9
          42 134 72 134 247 13 1 1 5 5 0 48 67 49 19 48 17 6 10 9
          146 38 137 147 242 44 100 1 25 22 3 99 111 109 49 23 48
          21 6 10 9 146 38 137 147 242 44 100 1 25 22 7 101 120
          97 109 112 108 101 49 19 48 17 6 3 85 4 3 19 10 69 120
          97 109 112 108 101 32 67 65 48 30 23 13 48 52 48 57 49
          53 49 49 52 56 50 49 90 23 13 48 53 48 51 49 53 49 49
          52 56 50 49 90 48 67 49 19 48 17 6 10 9 146 38 137 147
          242 44 100 1 25 22 3 99 111 109 49 23 48 21 6 10 9 146
          38 137 147 242 44 100 1 25 22 7 101 120 97 109 112 108
          101 49 19 48 17 6 3 85 4 3 19 10 69 110 100 32 69 110
          116 105 116 121 48 129 159 48 13 6 9 42 134 72 134 247
          13 1 1 1 5 0 3 129 141 0 48 129 137 2 129 129 0 225 106
          228 3 48 151 2 60 244 16 243 181 30 77 127 20 123 246
          245 208 120 233 164 138 240 163 117 236 237 182 86 150
          127 136 153 133 154 242 62 104 119 135 235 158 209 159
          192 180 23 220 171 137 35 164 29 126 22 35 76 79 168 77
          245 49 184 124 170 227 26 73 9 244 75 38 219 39 103 48
          130 18 1 74 233 26 182 193 12 83 139 108 252 47 122 67
          236 51 54 126 50 178 123 213 170 207 1 20 198 18 236 19
          242 45 20 122 139 33 88 20 19 76 70 163 154 242 22 149
          255 35 2 3 1 0 1 163 117 48 115 48 33 6 3 85 29 17 4 26
          48 24 129 22 101 110 100 46 101 110 116 105 116 121 64
          101 120 97 109 112 108 101 46 99 111 109 48 29 6 3 85
          29 14 4 22 4 20 23 123 146 48 255 68 214 102 225 144 16
          34 108 22 79 192 142 65 221 109 48 31 6 3 85 29 35 4 24
          48 22 128 20 8 104 175 133 51 200 57 74 122 248 130 147
          142 112 106 74 32 132 44 50 48 14 6 3 85 29 15 1 1 255
          4 4 3 2 6 192 48 13 6 9 42 134 72 134 247 13 1 1 5 5 0
          3 129 129 0 0 32 40 52 91 104 50 1 187 10 54 14 173 113
          197 149 26 225 4 207 174 173 199 98 20 164 27 54 49 192
          226 12 61 217 30 192 0 220 16 160 186 133 111 65 203 98
          122 183 76 99 129 38 94 210 128 69 94 51 231 112 69 59
          57 59 38 74 156 59 242 38 54 105 8 121 187 251 150 67
          119 75 97 139 161 171 145 100 224 243 55 97 60 26 163
          164 201 138 178 191 115 212 77 228 88 228 98 234 188 32
          116 146 134 14 206 132 96 118 233 115 187 199 133 211
          145 69 234 98 93 205))

(define rfc3280bis-cert3                ;DSA
  #vu8(48 130 3 142 48 130 3 78 160 3 2 1 2 2 2 1 0 48 9 6 7
          42 134 72 206 56 4 3 48 71 49 19 48 17 6 10 9 146 38
          137 147 242 44 100 1 25 22 3 99 111 109 49 23 48 21 6
          10 9 146 38 137 147 242 44 100 1 25 22 7 101 120 97 109
          112 108 101 49 23 48 21 6 3 85 4 3 19 14 69 120 97 109
          112 108 101 32 68 83 65 32 67 65 48 30 23 13 48 52 48
          53 48 50 49 54 52 55 51 56 90 23 13 48 53 48 53 48 50
          49 54 52 55 51 56 90 48 71 49 19 48 17 6 10 9 146 38
          137 147 242 44 100 1 25 22 3 99 111 109 49 23 48 21 6
          10 9 146 38 137 147 242 44 100 1 25 22 7 101 120 97 109
          112 108 101 49 23 48 21 6 3 85 4 3 19 14 68 83 65 32 69
          110 100 32 69 110 116 105 116 121 48 130 1 183 48 130 1
          44 6 7 42 134 72 206 56 4 1 48 130 1 31 2 129 129 0 182
          139 15 148 43 154 206 165 37 198 242 237 252 251 149 50
          172 1 18 51 185 224 28 173 144 155 188 72 84 158 243
          148 119 60 44 113 53 85 230 254 79 34 203 213 216 62
          137 147 51 77 252 189 79 65 100 62 162 152 112 236 49
          180 80 222 235 241 152 40 10 201 62 68 179 253 34 151
          150 131 208 24 163 227 189 53 91 255 238 163 33 114 106
          123 150 218 185 63 30 90 144 175 36 214 32 240 13 33
          167 212 2 185 26 252 172 33 251 158 148 158 75 66 69
          158 106 178 72 99 254 67 2 21 0 178 13 176 177 1 223 12
          102 36 252 19 146 186 85 247 125 87 116 129 229 2 129
          129 0 154 191 70 177 245 63 68 61 201 165 101 251 145
          192 142 71 241 10 195 1 71 194 68 66 54 169 146 129 222
          87 197 224 104 134 88 0 123 31 249 155 119 161 197 16
          165 128 145 120 81 81 60 246 252 252 204 70 198 129 120
          146 132 61 244 147 61 12 56 126 26 91 153 78 171 20 100
          246 12 33 34 78 40 8 156 146 185 102 159 64 232 149 246
          213 49 42 239 57 162 98 199 178 109 158 88 196 58 168
          17 129 132 109 175 248 180 25 180 194 17 174 208 34 59
          170 32 127 238 30 87 24 3 129 132 0 2 129 128 48 182
          117 247 124 32 49 174 56 187 126 13 43 171 160 156 75
          223 32 213 36 19 60 205 152 229 95 108 183 193 186 74
          186 169 149 128 83 240 13 114 220 51 55 244 1 11 245 4
          31 157 46 31 98 216 132 58 155 37 9 90 45 200 70 142 43
          212 245 13 59 199 45 198 108 185 152 193 37 58 68 78
          142 202 149 97 53 124 206 21 49 92 35 19 30 162 5 209
          122 36 28 203 211 114 9 144 255 155 157 40 192 161 10
          236 70 159 13 184 208 220 208 24 166 43 94 249 143 181
          149 190 163 129 202 48 129 199 48 57 6 3 85 29 17 4 50
          48 48 134 46 104 116 116 112 58 47 47 119 119 119 46
          101 120 97 109 112 108 101 46 99 111 109 47 117 115 101
          114 115 47 68 83 65 101 110 100 101 110 116 105 116 121
          46 104 116 109 108 48 33 6 3 85 29 18 4 26 48 24 134 22
          104 116 116 112 58 47 47 119 119 119 46 101 120 97 109
          112 108 101 46 99 111 109 48 29 6 3 85 29 14 4 22 4 20
          221 37 102 150 67 171 120 17 67 68 254 149 22 249 217
          182 183 2 102 141 48 31 6 3 85 29 35 4 24 48 22 128 20
          134 202 165 34 129 98 239 173 10 137 188 173 114 65 44
          41 73 244 134 86 48 23 6 3 85 29 32 4 16 48 14 48 12 6
          10 96 134 72 1 101 3 2 1 48 9 48 14 6 3 85 29 15 1 1
          255 4 4 3 2 7 128 48 9 6 7 42 134 72 206 56 4 3 3 47 0
          48 44 2 20 101 87 7 52 221 220 202 204 94 244 2 244 86
          66 44 94 225 179 59 128 2 20 96 244 49 23 202 244 207
          255 238 244 8 167 217 178 97 190 177 195 218 191))

(let ((cert1 (certificate<-bytevector rfc3280bis-cert1)))
  #;(print-certificate cert1)
  (check (decipher-certificate-signature cert1 cert1)
         =>
         '((sha1 #f) #vu8(40 133 68 67 27 139 209 192 46 100 229 224 59 71 75 231 162 201 27 29)))
  (check (sha-1->bytevector (sha-1 (certificate-tbs-data cert1)))
         =>
         #vu8(40 133 68 67 27 139 209 192 46 100 229 224 59 71 75 231 162 201 27 29))

  (check (verify-certificate-chain (list cert1))
         =>
         'self-signed)

  (let ((cert2 (certificate<-bytevector rfc3280bis-cert2)))
    #;(print-certificate cert2)

    (check (decipher-certificate-signature cert2 cert1)
           =>
           '((sha1 #f) #vu8(0 46 123 152 4 85 233 72 143 151 119 59 247 169 178 151 164 80 223 122)))

    (check (sha-1->bytevector (sha-1 (certificate-tbs-data cert2)))
           =>
           #vu8(0 46 123 152 4 85 233 72 143 151 119 59 247 169 178 151 164 80 223 122))

    ))
