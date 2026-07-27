# Documento de Visão e Requisitos

Projeto: WiaLog ERP

Plataforma Alvo: Windows Desktop (com arquitetura preparada para mobile futuro)

Arquitetura: Clean Architecture + BLoC

Banco de Dados: Local (PostgreSQL / SQL Server)

## 1. Visão Geral do Produto

O WiaLog ERP é um sistema de gestão voltado para pequenas e médias empresas de transporte. O objetivo principal do MVP (Minimum Viable Product) é centralizar o controle de frotas, manutenções e o fluxo financeiro (contas a pagar e receber), garantindo que a operação funcione de forma offline/local e oferecendo controle estrito de acesso baseado em papéis (RBAC).

## 2. Atores (Perfis de Usuário)

Administrador: Acesso irrestrito a todos os módulos, configurações do sistema e gestão de usuários.

Fiscal (Operacional): Acesso ao cadastro de frotas, abertura e fechamento de ordens de manutenção. Sem acesso a valores sensíveis do fluxo de caixa.

Financeiro / Contador: Acesso exclusivo ao módulo financeiro (Contas a Pagar, Receber e Relatórios). Pode visualizar manutenções apenas para fins de auditoria de custos.

Atendente: Acesso restrito apenas para consultas rápidas de status de veículos.

## 3. Requisitos Funcionais (RF)

### O que o sistema deve fazer.

    3.1 Módulo de Autenticação

RF01: O sistema deve permitir login com E-mail e Senha.

RF02: O sistema deve carregar as permissões do usuário logado e bloquear telas não autorizadas.

    3.2 Módulo de Frotas (Operacional)

RF03: O sistema deve permitir o CRUD (Criar, Ler, Atualizar, Excluir) de Veículos (Placa, Modelo, Ano, Chassi, Renavam).

RF04: O sistema deve gerenciar o status do veículo (Disponível, Em Viagem, Em Manutenção, Inativo).

RF05: O sistema deve permitir o registro de Ordens de Manutenção (Preventiva ou Corretiva), contendo data, descrição da falha, oficina parceira e valor do orçamento.

    3.3 Módulo Financeiro

RF06: O sistema deve permitir o lançamento de Contas a Pagar (despesas da frota, salários, aluguel, etc).

RF07: O sistema deve permitir o lançamento de Contas a Receber (receitas de fretes).

RF08: O sistema deve permitir a alteração de status financeiro (Pendente, Pago, Atrasado, Cancelado).

RF09: O sistema deve gerar um fluxo de caixa simples filtrável por período (mês/ano).

## 4. Regras de Negócio (RN)

Condições que o sistema deve respeitar sempre.

RN01 (Integração Frota-Financeiro): Sempre que uma Ordem de Manutenção for marcada como "Concluída", o sistema deve gerar automaticamente um registro de "Conta a Pagar" pendente no módulo financeiro com o valor da manutenção.

RN02 (Exclusão Lógica): Um veículo que já possui histórico de manutenção ou histórico financeiro atrelado à sua placa não pode ser excluído do banco de dados. Ele deve ser marcado como "Inativo" (Soft Delete).

RN03 (Baixa Financeira): Apenas usuários com perfil "Admin" ou "Financeiro" podem alterar o status de uma conta para "Pago".

RN04 (Unicidade): Não pode haver dois veículos cadastrados com a mesma Placa ou Chassi ativos no sistema.

## 5. Requisitos Não Funcionais (RNF)

Restrições e atributos de qualidade do sistema.

RNF01 (Tecnologia): Desenvolvido em Flutter Desktop para Windows.

RNF02 (Banco de Dados): O banco de dados relacional deve rodar na rede local do cliente. O acesso a dados não dependerá de internet.

RNF03 (Arquitetura): O código deve seguir estritamente a Clean Architecture, isolando a camada de domain das dependências externas.

RNF04 (Gerenciamento de Estado): Utilização do padrão BLoC (Business Logic Component) para reatividade da UI.

RNF05 (Tratamento de Erros): O sistema deve capturar falhas de conexão com o banco local e exibir SnackBar amigável, impedindo o crash (fechamento abrupto) do app.

## 6. Próximos Passos (Roadmap MVP)

 Configuração de Banco de Dados Local (Criação de Tabelas).

Implementação da Home/Dashboard (Menu Lateral de navegação).

Desenvolvimento do Módulo de Frotas (Ponta a ponta: Domain -> Data -> UI).

Desenvolvimento do Módulo Financeiro.

Geração de Relatórios/Exportação básica (PDF/Excel).