# Fase 2 — Contrato inicial do handshake do mundo

Data: 2026-09-23. Cliente de referência em `d4ae7cf2dc058d82bc375faf44c6eecc3dd9fa84`; servidor em `f42413eff8d59b04087b52d1b793a4c685de5a82`.

## Desafio inicial do servidor

O perfil 15.25 usa `ServerChallengeBeforeLogin`. Antes de receber o login, o servidor envia um frame moderno cujo corpo não está criptografado e possui 12 bytes:

1. Adler-32 little-endian de quatro bytes, calculado sobre os oito bytes seguintes;
2. marcador `0x01`, consumido pelo cliente como byte inicial do pacote moderno;
3. opcode `0x1F`;
4. timestamp little-endian de 32 bits;
5. byte aleatório;
6. trailer `0x71`.

O decoder deste incremento exige comprimento exato e valida checksum, marcador, opcode e trailer antes de expor timestamp e byte aleatório. Ele opera somente sobre o corpo já separado pelo envelope externo implementado na Fase 1.

## Login subsequente confirmado

Após validar o desafio, o cliente monta o login com identificador de protocolo `0x000A`, sistema operacional, versão de protocolo 1525, versão de cliente de 32 bits, duas strings de versão/asset e preview state. O bloco RSA de 128 bytes começa com zero, contém quatro palavras XTEA, flag de game master, chave de sessão, personagem, timestamp e byte aleatório, seguido pelo probe OTCv8 e padding. O servidor descriptografa esse bloco antes de habilitar XTEA.

A escrita exata do bloco RSA, sua chave pública, o probe estendido, checksum/sequência externa e a ativação da criptografia serão implementados em incrementos separados. Nenhum pacote de login foi produzido ou enviado nesta etapa.

Validação externa de 2026-09-23: o responsável informou `100% tests passed, 0 tests failed out of 82`. Os seis testes adicionais cobrem uma fixture moderna conhecida, comprimento inesperado, checksum inválido, marcador inicial inválido, opcode inválido e trailer inválido.

## Catálogo e primitivas binárias

Constantes do handshake ficam em um catálogo interno com nomes de domínio, incluindo tamanhos, offsets, marcadores, opcode, versão, identificador do login e dimensões de RSA/XTEA. Leitura e escrita little-endian e Adler-32 ficam em módulos binários reutilizáveis. Fixtures conhecidas mantêm bytes literais como evidência independente; mutações e código de produção usam os nomes do catálogo.

Validação externa de 2026-09-23: após a extração do catálogo e das primitivas binárias, o responsável informou `100% tests passed, 0 tests failed out of 86`. Os quatro testes adicionais cobrem leitura little-endian, recusa de leitura fora dos limites, escrita little-endian e um vetor Adler-32 conhecido.
