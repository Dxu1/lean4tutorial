# Log consolidation

Three tool logs emitted trailing whitespace. Only trailing whitespace and terminal blank lines were removed from their review copies so the complete Git diff is whitespace-clean. No diagnostic or command result was removed or altered. Original raw byte copies remain under ignored `tmp/01_raw_logs/`. All other logs, including successful Lean builds, direct audit and exact signatures, retain their original output bytes plus recorded exit status.

- `docs_build.log`: original SHA-256 `20614f3237cab1e9b44158f8aff8d7e8c6ea4e0dffe54d45ca8a6e607b5ff09d`; consolidated SHA-256 `c644030a29c1d86c651d4f8e95f46810e8bc36021c84c1365712b525afb6604f`.
- `examples_attempt.log`: original SHA-256 `f7047a504430a7321f9a987a7e71ed398a43a2ad741527c659fd550a23cc5168`; consolidated SHA-256 `666709a4a8fabc6eebf51afbee05347be22e5d4a0600a3de8d56e6f0f5a01c66`.
- `utility_attempt.log`: original SHA-256 `e8ae04230301c34b54897ecfbdcb2e36df82876a83afb4014a0272bdbe67310b`; consolidated SHA-256 `9b4fe939306a197d6c963e1fd057faac92eec4f8c4ed65e79f20964f1ae5b38a`.
