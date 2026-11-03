# Contrato esperado: telas de Progresso e Conclusão

Este documento diz o que as telas **Seu progresso** e **Implantação concluída**
precisam do back. As telas já estão prontas e hoje leem dados fixos
(`ProgressoRepositoryMock`). Quando o back expuser os endpoints abaixo, o front
liga a implementação real (`ProgressoRepositoryApi`) sem mexer nas telas.

Os caminhos e nomes de campo são uma **proposta do front**. Se o back preferir
outros, basta alinhar e ajustar `ProgressoRepositoryApi` e os `fromJson` dos
modelos em `lib/features/progresso/domain`.

## Regras gerais

- As duas rotas exigem `Authorization: Bearer <token>` da sessão. O integrante
  e a empresa vêm do token, nunca da URL nem do corpo, como no resto da API.
- Números são inteiros. Percentuais vão de 0 a 100, já arredondados.
- Datas em ISO 8601 com fuso (ex.: `2026-08-14T15:30:00Z`). O app converte
  para o fuso do aparelho.
- Erro segue o formato padrão do back (`ErroResposta`). O app troca o erro
  por uma mensagem para o integrante, com um botão "Tentar novamente":

  | Resposta do back | Mensagem no app |
  |---|---|
  | `401` | Sessão expirou, entrar de novo. |
  | `403` | Conta sem acesso, falar com o administrador da empresa. |
  | `codigo` = `CONCLUSAO_NAO_EMITIDA` (ou `404` na conclusão) | Ainda não concluiu a implantação, terminar trilhas e checklist. |
  | `5xx` | Servidor instável, tentar em alguns minutos. |
  | Sem conexão | Verificar a internet. |
  | Qualquer outro | "Não foi possível carregar…", tentar de novo. |

  As frases ficam em `lib/features/progresso/presentation/mensagens_erro.dart`.
- Campo faltando ou com tipo errado faz a tela mostrar erro, com o nome do
  campo no log. O app não inventa valor padrão.

## `GET /api/v1/progresso/resumo`

Usado pela tela **Seu progresso**.

```json
{
  "xpTotal": 240,
  "nivel": 2,
  "nomeNivel": "Operador",
  "xpInicioNivel": 200,
  "xpProximoNivel": 400,
  "diasSeguidos": 4,
  "percentualAcertoQuiz": 92,
  "trilhasConcluidas": 1,
  "totalTrilhas": 3,
  "conquistas": [
    { "codigo": "PRIMEIRO_CANAL", "titulo": "Primeiro canal", "conquistada": true, "pendencia": null },
    { "codigo": "QUIZ_SEM_ERRO", "titulo": "Quiz sem erro", "conquistada": true, "pendencia": null },
    { "codigo": "SEQUENCIA_DIAS", "titulo": "Sequência de 4 dias", "conquistada": true, "pendencia": null },
    { "codigo": "IMPLANTACAO_COMPLETA", "titulo": "Implantação completa", "conquistada": false, "pendencia": "Faltam 2 trilhas" }
  ]
}
```

| Campo | O que a tela faz com ele |
|---|---|
| `xpTotal` | Número grande no topo ("240 XP"). |
| `nivel`, `nomeNivel` | Linha "NÍVEL 2 · Operador". |
| `xpInicioNivel`, `xpProximoNivel` | Barra do nível e o texto "160 XP para o próximo nível". O app calcula a fração e o que falta, então o back não precisa mandar esses dois valores prontos. |
| `diasSeguidos` | Indicador "dias seguidos". Pela regra do back, a sequência é calculada no fuso da empresa. |
| `percentualAcertoQuiz` | Indicador "acerto nos quizzes". |
| `trilhasConcluidas`, `totalTrilhas` | Indicador "1/3 trilhas concluídas". Ver a observação sobre "trilha" no fim. |
| `conquistas` | Lista de conquistas, na ordem recebida. `codigo` escolhe o ícone. Código desconhecido aparece com ícone genérico, sem quebrar a tela. `pendencia` só é exibida quando `conquistada` é `false`. |

Códigos de conquista que o app já conhece: `PRIMEIRO_CANAL`, `QUIZ_SEM_ERRO`,
`SEQUENCIA_DIAS`, `IMPLANTACAO_COMPLETA`.

## `GET /api/v1/progresso/conclusao`

Usado pela tela **Implantação concluída**.

```json
{
  "nomeIntegrante": "Marina Rocha",
  "numeroSelo": 412,
  "trilhasConcluidas": 3,
  "totalTrilhas": 3,
  "quizzesRealizados": 9,
  "percentualAcertoQuiz": 92,
  "itensConfiguracao": 14,
  "emitidoEm": "2026-08-14T15:30:00Z"
}
```

| Campo | O que a tela faz com ele |
|---|---|
| `nomeIntegrante` | "Olá, Marina" (primeiro nome) e o avatar "MR" (iniciais do primeiro e do último nome). |
| `numeroSelo` | "Nº 0412" (o app completa com zeros à esquerda até 4 dígitos). |
| `trilhasConcluidas`, `totalTrilhas` | Linha "Trilhas: 3 de 3". |
| `quizzesRealizados`, `percentualAcertoQuiz` | Linha "Quizzes: 9 · 92%". |
| `itensConfiguracao` | Linha "Itens de configuração: 14" (itens marcados no Checklist da trilha). |
| `emitidoEm` | Linha "Emitido em: 14 ago 2026". |

Integrante que ainda não concluiu a implantação: o front sugere `404` com
`codigo` = `CONCLUSAO_NAO_EMITIDA`. A tela mostra "Você ainda não concluiu a
implantação. Termine as trilhas e o checklist para receber o selo."

## O que mais depende de decisão ou do back

| Item na tela | O que falta |
|---|---|
| Compartilhar selo | Decidir o que é compartilhado (imagem do selo ou link público) e aprovar o pacote `share_plus`. Se for link, o back precisa gerar a URL pública do selo. |
| Relatório da implantação | Endpoint que gere o relatório (PDF ou link) para o gestor. |
| Trilha avançada: chatbot | Conteúdo da trilha avançada no back. O subtítulo "4 vídeos · 12 min" deveria vir de lá. |
| Falar com a Naty | Número de WhatsApp do suporte e aprovação do pacote `url_launcher`. |
| Entrada na tela de Conclusão | A tela de Checklist deve navegar para `/conclusao` ao concluir a última trilha. |

## Observação sobre "trilha"

No Figma, "Trilha 1 de 3" corresponde ao que o back chama de **módulo**. No
back, a trilha é o conteúdo inteiro. Os campos `trilhasConcluidas` e
`totalTrilhas` acima seguem o sentido do Figma (módulos). Vale alinhar o nome
antes de implementar, para a contagem não sair errada.
