# Avaliação de movimento do percurso

Superfície Operate: o movimento explica avanço e resposta às ações. A interface mantém o mapa contínuo, os títulos fixos por seção e a paleta existente. Avaliação feita sobre os componentes atuais com o playbook de animação do Impeccable.

## Implementação

| Ponto | Comportamento implementado | Duração |
| --- | --- | --- |
| Troca de telas | Fade com deslocamento discreto na entrada da aula; retorno mais curto e posição do mapa preservada. | 220 / 160 ms |
| Toque nos botões | Escala até 0,97 nos botões principais e nós do mapa; mantém ripple, foco e cancelamento do toque. | 120 ms |
| Carregamento | Placeholder inicial e fade para os dados; recarga conserva mapa e posição com barra fina; falha oferece nova tentativa. | Fade de 180 ms; barra durante a requisição |
| Aula concluída | Onda verde, check e escala, uma vez por conclusão confirmada pela API. | Sequência finita existente |
| Trilha concluída | Depois da onda, destaque do check no título e, em seguida, da próxima seção liberada. | 650 ms por etapa |
| Rolagem entre trilhas | Passagem natural dos cabeçalhos fixos, sem repetir entradas ao rolar. | Vinculada à rolagem |

## Critérios preservados

- Disparar conclusão de trilha somente na transição entre incompleta e completa; abrir o app com histórico concluído não dispara celebração.
- Carregamento e falha não contam como progresso; conservar dados e oferecer nova tentativa.
- Não empilhar celebração da aula e da trilha no mesmo instante.
- Respeitar `MediaQuery.disableAnimations`: remover ondas, deslocamento e escala, mantendo estado, cor e check.
- Encerrar animações finitas e não manter loops decorativos em trilhas fora da tela.
- Verificar toque repetido, retorno do quiz, rolagem durante atualização e nomes longos com texto ampliado.

As propostas foram implementadas: AppRouter aplica fade de 220 ms com deslocamento discreto na entrada da aula e retorno de 160 ms; PressFeedback usa flutter_animate nos botões principais e nós do mapa; GradientButton faz a troca suave entre rótulo e carregamento. A primeira carga mostra um placeholder estável, e a recarga conserva o percurso e a posição, com barra indeterminada e recuperação de erro.

A conclusão segue a ordem onda da última aula → destaque do título por 650 ms → destaque da próxima trilha liberada por 650 ms. As etapas são finitas e disparadas por mudança real do progresso. Em redução de movimento, check e estado são atualizados diretamente; a barra de carregamento fica estática e sem percentual fictício.
