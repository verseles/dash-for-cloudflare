# Dash for Cloudflare - Agent Instructions

Sempre que iniciar qualquer sessão siga as regras e orientações dos arquivos:

- @./ADR.md
- @./README.md
- @./roadmap/roadmap.md

---

## Regras de Trabalho Autônomo

1. Sempre que necessário ou mencionado "projeto original", "projeto Vue", "projeto antigo", visite o projeto original (branch `old_vue`) para esclarecer o funcionamento anterior funcional
2. Use web search com frequência, antes de cada solicitação ou no modo planejamento, nem sempre para resolver erros, mas para confirmar que usará o método mais eficiente e moderno ou comparar possibilidades
3. Se ficar preso em erros, use web search para resolver
4. Para cada web search aguarde 1 segundo após o recebimento da resposta para fazer uma nova pesquisa
5. A cada fase concluída, atualize o roadmap, faça um commit bem descrito. Faça push apenas caso o usuário já tenha pedido alguma vez na conversa atual
6. Sempre monte o to-do list das fases pendentes, e sub fases
7. Se ficar completamente preso sem opções de resolver sozinho, chame a tool play_notification e pare até receber uma resposta do usuário. Mas priorize soluções autônomas.
8. Esse projeto não está em produção, portanto, não é necessário preocupar com compatibilidade com versões anteriores, refatore livremente conforme necessário.
9. Use @./precommit.sh como um gatekeeper sempre antes de qualquer commit. Para evitar ler logs de uma execução de sucesso redirecione a saída para um arquivo na pasta tmp do OS e use || para verificar se houve erro e só então ler os logs. A intenção é evitar ler logs de uma execução de sucesso sem necessidade.
10. Crie novos tests e atualize os existentes conforme necessário para garantir a qualidade do código.

---

## Referência Rápida

| Campo               | Valor                                    |
| ------------------- | ---------------------------------------- |
| **Nome**            | Dash for Cloudflare                      |
| **Package ID**      | `ad.dash.cf`                             |
| **Web URL**         | `cf.dash.ad`                             |
| **Plataformas**     | Android, iOS, Web, Linux, macOS, Windows |
| **Plataformas Dev** | Android, Linux                           |
| **Repositório**     | github.com/verseles/dash-for-cloudflare  |
| **Branch Vue**      | `old_vue` (projeto original)             |
