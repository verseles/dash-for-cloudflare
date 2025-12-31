# Dash for Cloudflare - Agent Instructions

Sempre que iniciar qualquer sessão siga as regras e orientações dos arquivos:

- @./ADR.md
- @./README.md
- @./roadmap/roadmap.md

---

## Regras de Trabalho

1. Sempre que necessário ou mencionado "projeto original", "projeto Vue", "projeto antigo", visite o projeto original (branch `old_vue`) para esclarecer o funcionamento anterior funcional
2. Use web search com frequência, antes de cada solicitação ou no modo planejamento, nem sempre para resolver erros, mas para confirmar que usará o método mais eficiente e moderno ou comparar possibilidades
3. Se ao usar r.jina.ai/endereço falhar, tente novamente diretamente no endereço original.
4. Se ficar preso em erros, use web search para resolver
5. Para cada web search aguarde 1 segundo após o recebimento da resposta para fazer uma nova pesquisa
6. A cada fase concluída, atualize o roadmap, faça um commit bem descrito. Faça push apenas caso o usuário já tenha pedido alguma vez na conversa atual
7. Sempre monte o to-do list das fases pendentes, e sub fases
8. Chame a tool `play_notification` nos seguintes casos:
   - Ao finalizar um trabalho/tarefa grande
   - Ao finalizar um planejamento
   - Se ficar completamente preso sem opções de resolver sozinho (pare e aguarde resposta)
   Priorize soluções autônomas antes de parar por estar preso.
9. Esse projeto não está em produção, portanto, não é necessário preocupar com compatibilidade com versões anteriores, refatore livremente conforme necessário.
10. **OBRIGATÓRIO: Use `make precommit` como gatekeeper antes de QUALQUER commit.** Este comando já inclui supressão de logs de sucesso para economizar tokens. NÃO use `./precommit.sh` diretamente.
11. Para evitar ler logs de uma execução de sucesso redirecione a saída para um arquivo na pasta tmp do OS. Use algo como `comando > /tmp/comando.log 2>&1 || cat /tmp/comando.log` (algo assim, adapte) para verificar se houve erro e só então ler os logs. A intenção é evitar ler logs de uma execução de sucesso sem necessidade. Use para verificar logs de compilação, testes, precommit, etc.
12. Crie novos tests e atualize os existentes conforme necessário para garantir a qualidade do código.
13. **Use os comandos `make` disponíveis em vez de comandos Flutter/Dart diretos.** Os comandos make já incluem supressão de logs para economizar tokens.

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

Use SEMPRE os comandos make em vez de comandos Flutter/Dart diretos. Eles incluem supressão de logs de sucesso para economizar tokens.

| Comando           | Descrição                                          |
| ----------------- | -------------------------------------------------- |
| `make precommit`  | **OBRIGATÓRIO antes de commit** - verificação completa |
| `make android`    | Build APK (arm64) + upload via tdl                 |
| `make android-x64`| Build APK (x64 para emulador)                      |
| `make linux`      | Build Linux release                                |
| `make web`        | Build Web release                                  |
| `make test`       | Executar testes                                    |
| `make analyze`    | Análise estática                                   |
| `make deps`       | Instalar dependências                              |
| `make gen`        | Gerar código (Freezed, Retrofit)                   |
| `make clean`      | Limpar artefatos de build                          |
| `make install`    | Instalar no Linux (~/.local)                       |
| `make uninstall`  | Desinstalar do Linux                               |

### Fluxo de Trabalho

```bash
# Após fazer alterações no código:
make precommit    # Verifica tudo antes de commit

# Para builds específicas:
make android      # Build + upload para Telegram
make linux        # Build Linux

# Para desenvolvimento:
make deps         # Após alterar pubspec.yaml
make gen          # Após alterar models Freezed/Retrofit
```
