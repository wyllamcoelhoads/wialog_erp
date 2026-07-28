name: Feature Request (Requisito Funcional) about: Sugira uma nova funcionalidade para o WiaLog ERP title: 'feat: [Nome da Funcionalidade]' labels: 'enhancement' assignees: ''
📋 Descrição do Requisito
🎯 Critérios de Aceite (Definition of Done)

    [ ] O veículo deve ser salvo no banco de dados local.

    [ ] A tela deve exibir uma mensagem de sucesso verde.

    [ ] O BLoC deve emitir o estado de Loaded após o salvamento.

📐 Arquitetura (Clean Architecture)

    Camada Data: (ex: criar VehicleModel e VehicleRepositoryImpl)

    Camada Domain: (ex: criar entidade Vehicle e UseCase AddVehicle)

    Camada Presentation: (ex: criar VehicleFormPage e VehicleBloc)

🖼️ Telas / Mockups (Opcional)