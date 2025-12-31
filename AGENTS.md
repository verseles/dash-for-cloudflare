# Dash for Cloudflare - Agent Instructions

Sempre que iniciar qualquer sessão, leia os arquivos de contexto:

- @./ADR.md
- @./README.md
- @./roadmap/roadmap.md

---

## Referência Rápida

| Campo               | Valor                                                     |
| ------------------- | --------------------------------------------------------- |
| **Nome**            | Dash for Cloudflare                                       |
| **Package ID**      | `ad.dash.cf`                                              |
| **Web URL**         | `cf.dash.ad`                                              |
| **Plataformas**     | Android, iOS, Web, Linux, macOS, Windows                  |
| **Plataformas Dev** | Android, Linux                                            |
| **Repositório**     | github.com/verseles/dash-for-cloudflare                   |
| **Branch Vue**      | `old_vue` (projeto original que foi migrado para Flutter) |

---

## Comandos Make (OBRIGATÓRIO)

Use SEMPRE comandos make. Eles suprimem logs de sucesso para economizar tokens.

| Comando           | Descrição                                    | Tempo   |
| ----------------- | -------------------------------------------- | ------- |
| `make check`      | Validação rápida (deps+gen+analyze+test)     | ~20s    |
| `make precommit`  | Verificação completa (check+builds)          | ~30s    |
| `make android`    | Build APK (arm64) + upload via tdl           | ~30s    |
| `make android-x64`| Build APK (x64 para emulador)                | ~30s    |
| `make linux`      | Build Linux release                          | ~10s    |
| `make web`        | Build Web release                            | ~20s    |
| `make test`       | Executar testes                              | ~10s    |
| `make analyze`    | Análise estática                             | ~3s     |
| `make deps`       | Instalar dependências                        | ~2s     |
| `make gen`        | Gerar código (Freezed, Retrofit)             | ~5s     |
| `make clean`      | Limpar artefatos de build                    | ~2s     |
| `make install`    | Instalar no Linux (~/.local)                 | -       |
| `make uninstall`  | Desinstalar do Linux                         | -       |

### Fluxo de Trabalho

```bash
# Durante desenvolvimento (várias vezes):
make check

# Antes de commit (uma vez):
make precommit

# Para builds específicas:
make android      # Build + upload para Telegram
make linux        # Build Linux

# Após alterar dependências ou models:
make deps         # Após alterar pubspec.yaml
make gen          # Após alterar models Freezed/Retrofit
```

---

## Regras de Trabalho

### Build & Commit

1. **`make check` durante desenvolvimento.** Validação rápida (~20s) para feedback iterativo.

2. **`make precommit` antes de QUALQUER commit.** Verificação completa incluindo builds.

3. **Commit a cada fase concluída.** Atualize o roadmap e faça commit bem descrito.

4. **Push só se já pedido na sessão.** Não faça push automaticamente, apenas se o usuário já pediu pelo menos uma vez na conversa atual.

5. **Se `make analyze` ou `make test` falhar, corrija TODOS os erros.** Não prossiga com erros pendentes.

### Desenvolvimento

6. **To-do list sempre atualizado.** Monte e mantenha a lista de fases/sub-fases pendentes.

7. **Testes atualizados.** Crie novos testes e atualize existentes conforme necessário.

8. **Refatoração livre.** Projeto não está em produção, não precisa de compatibilidade com versões anteriores.

9. **Para features grandes, crie branch.** Use `feature/nome`. Após PR aprovado, retorne para main.

### Web Search

10. **Use web search com frequência:**
    - Para confirmar métodos eficientes/modernos
    - Para resolver erros quando ficar preso
    - Aguarde 1 segundo entre pesquisas (evitar rate limit)
    - Se r.jina.ai falhar, tente a URL original

### Notificações

11. **Chame `play_notification` nos seguintes casos:**
    - Ao finalizar um trabalho/tarefa grande
    - Ao finalizar um planejamento
    - Se ficar completamente preso sem solução (pare e aguarde resposta)

    Priorize soluções autônomas antes de parar.

### Logs

12. **Suprima logs de sucesso.** Para comandos fora do make:
    ```bash
    cmd > /tmp/cmd.log 2>&1 || cat /tmp/cmd.log
    ```

### Documentação

13. **Atualize AGENTS.md quando mudanças o afetarem.** Novas regras, comandos, fluxos ou convenções devem ser refletidos aqui.

14. **Atualize ADR.md para decisões técnicas relevantes.** Adicione novo ADR ou atualize existente quando: escolher biblioteca/abordagem, resolver problema arquitetural, ou tomar decisão que afete desenvolvimento futuro.

### Referências

15. **Branch `old_vue` para consultar projeto original.** Sempre que mencionado "projeto Vue" ou "projeto antigo".

16. **Testar no emulador:** `flutter run` ou instale APK de `make android-x64`.

---

## Não Fazer

- **NÃO** use `./precommit.sh` (use `make precommit`)
- **NÃO** use comandos Flutter/Dart diretos (use `make`)
- **NÃO** faça push sem o usuário ter pedido na sessão atual
- **NÃO** ignore erros de `make analyze` ou `make test`
- **NÃO** leia logs de comandos que passaram (desperdiça tokens)
- **NÃO** prossiga com erros pendentes
