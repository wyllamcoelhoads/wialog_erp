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

RF10: O sistema deve permitir o cadastros de fornecedores e clientes, devendo existir duas telas distintas para o cadastro de cliente e de fornecedores (Para clientes deve ser possivel cadadastrar CPF/CNPJ,Razão social, Nome fantasia, um flag informando se o cliente é fisico ou juridico, contato e e-mail, dados de cobrança, endereço,obs  e etc ).

    3.4 Módulo de Segurança e Licenciamento (SaaS)

RF01: O sistema deve validar a licença de uso conectando-se a um banco de dados em nuvem (Firebase) durante a inicialização ou login.

RF02: A validação será feita através do CNPJ da empresa cliente. A nuvem deve retornar o status da assinatura (Ativo, Bloqueado) e uma Data de Validade Limite (ex: data do próximo vencimento + 5 dias de carência).

RF03: Sempre que a validação online for bem-sucedida, o sistema deve salvar essa "Data de Validade Limite" de forma segura no ambiente local da máquina.

RF04: Em caso de falha de conexão com a internet (timeout), o sistema deve operar no modo de Tolerância Offline, permitindo o acesso se a data atual do computador for menor ou igual à "Data de Validade Limite" salva localmente.

RF05: Caso a internet esteja ativa e retorne status "Bloqueado", ou a internet esteja offline e a "Data Limite" local tenha expirado, o acesso deve ser negado com a mensagem "Assinatura Inativa ou Expirada - Contate o Suporte".

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

RNF06 - Segurança Local: A data de validade guardada localmente deve ser ofuscada ou criptografada (ex: pacote flutter_secure_storage) para dificultar a alteração maliciosa pelo cliente.

## 6. Próximos Passos (Roadmap MVP)

 Configuração de Banco de Dados Local (Criação de Tabelas).

Implementação da Home/Dashboard (Menu Lateral de navegação).

Desenvolvimento do Módulo de Frotas (Ponta a ponta: Domain -> Data -> UI).

Desenvolvimento do Módulo Financeiro.

Geração de Relatórios/Exportação básica (PDF/Excel).