
# App Agenda

App onde consiste em cadastrar agendamentos via aplicativo, e receber notificações referente ao agendamento 

## Stack utilizada

**Front-end:** Swift, UIKit, RxRelay, RxSwift, RxCocoa e SnapKit

## Arquitetura do app

Foi utilizado a arquitetura MVVM (Model-View-ViewModel) para garantir uma melhor organização do código, facilitar a manutenção e escalabilidade da aplicação. A separação permite:

- View: Responsável apenas pela interface e interação com o usuário.

- ViewModel: Contém a lógica de apresentação, processa os dados vindos do Model e prepara-os para exibição.

- Model: Representa os dados e regras de negócio da aplicação.


## Funcionalidades presentes

- ✅ Listagem de agendamentos
- ✅ Empty view para quando não existe agendamentos
- ✅ Cadastro de novos agendamentos
- ✅ Swipe no item da lista, dando opção de editar ou remover um agendamento
- ✅ Edição de um agendamentos ja cadastrado 
- ✅ Remoção de um agendamento
- ✅ Modal com detalhes do agendamento
- ✅ Chegada de notificação de acordo com a data e horario cadastrado
- ✅ DatePicker de calendário para seleção da data do agendamento
- ✅ DatePicker de horas para selecionar o horário do agendamento
- ✅ UIPickerView seleção de item, opção do cliente selecionar com quanto tempo antes ele deseja receber a notificação


## Funcionalidades pendentes 

- ❌ Toaster de feedback ao cadastrar, remover ou editar um agendamento
- ❌ Ao editar ou remover um agendamento, refletir na notificação


