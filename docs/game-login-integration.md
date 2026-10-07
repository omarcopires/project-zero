# Login and world-entry integration

## Connected flow

The original `gamewindow.qml` receives a Qt controller. Its login form sends credentials to `AuthenticationService` through `network/login_service_url`. A successful response populates `CharacterSelector` and opens the original `CharacterSelection.qml` with returned character and world names. Rejected credentials, transport failures, and unsupported verification challenges remain separate states. The client does not bypass two-factor authentication or log passwords and session keys.

After confirmation of exactly one character, the controller resolves the world endpoint, generates a random XTEA key, and starts `WorldSessionService`. The UI enters `INGAME` only after the world session is accepted and an initial map description is decoded. That description is passed to `WorldMapItem`; rendering is still limited to static sprites from one field.

## Local configuration

The client reads `client.ini` beside the executable. `CLIENT_CONFIG_FILE` can select another file. Copy `client/config/local.example.ini` and configure:

- `network/login_service_url`: laboratory HTTP login service.
- `network/world_host` and `network/world_port`: set both to override the world endpoint from login, or leave both empty to use the response.
- `network/asset_hash_identifier`: optional world-login asset identifier. The laboratory 15.25 server reads and logs this field without validating it; the client sends an empty string when it is unset.
- `assets/directory`: catalog and sprite directory, defaulting locally to `things/assets`. `CLIENT_ASSETS_DIRECTORY` takes precedence.

The client does not invent an asset hash. Matching local asset IDs to the server is still an external validation gate; see [asset verification](phase0-assets-verification.md).

## Known limits

- Two-factor challenges have an explicit unsupported state; code entry and resend are not connected.
- Selection exposes character and world names. Outfit, premium state, hidden status, pins, store, calendar, and live indicators are not supplied by the available authentication response.
- The initial world map is shown after decoding; floors, layers, animation, lighting, movement, HUD, chat, and commands are outside this integration.
- The layout reserves map and chat space; sidebars are empty until inventory, container, and other models/controllers are connected.
- Remember-email persists only the address when enabled; it never saves the password.

The historical integration review was static. At that point compilation, 158 tests, and the server flow remained pending external validation for those changes. This statement is not a current test result.
