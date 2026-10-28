# limpar-perfis-windows

Script PowerShell para remover perfis de usuário em lote no Windows, mantendo apenas os perfis definidos em uma lista de exceções.


## O que ele faz

O script faz o mesmo que o botão **Excluir** em:
`Propriedades do Sistema > Avançado > Perfis de Usuário > Configurações`

Ele usa a classe `Win32_UserProfile`, que remove **a pasta do perfil** (`C:\Users\<usuario>`) **e a entrada no registro**. Isso evita perfis corrompidos ou temporários, que aparecem quando se apaga só a pasta.

O script **não apaga**:
- perfis do sistema (SYSTEM, Serviço Local, Serviço de Rede)
- o perfil do usuário que está logado
- os perfis da lista de exceções (`$Manter`)

> Apenas o **perfil local** é removido. A conta do usuário continua existindo (no domínio ou localmente) e um perfil novo é criado no próximo login. Arquivos salvos localmente (Área de Trabalho, Documentos, Downloads) **são apagados definitivamente**, sem passar pela lixeira.

## Requisitos

- Windows 10 ou 11
- PowerShell 5.1 ou superior
- Executar como **Administrador**

## Configuração

No início do script, edite a lista `$Manter` com os perfis que **nunca** devem ser apagados:

```powershell
$Manter = @(
    'Administrador',
    'Administrator',
    'Default',
    'Public',
    'defaultuser0'
)
```

A lista aceita curinga. Por exemplo, `'adm.*'` mantém todos os perfis que começam com `adm.`.

## Como usar

Abra o PowerShell **como Administrador** e vá até a pasta do script.

**1. Simule primeiro** (só mostra o que seria apagado):

```powershell
powershell -ExecutionPolicy Bypass -File .\LimparPerfis.ps1 -Simular
```

**2. Confira a lista e, se estiver correta, execute de verdade:**

```powershell
powershell -ExecutionPolicy Bypass -File .\LimparPerfis.ps1
```

>  **Não cole o conteúdo do script direto na janela do PowerShell.** Nesse modo o parâmetro `-Simular` é ignorado e o script **apaga os perfis de verdade**. Sempre execute como arquivo, com `-File`.

## Log

Cada execução gera um log em:

```
C:\Windows\Temp\LimparPerfis_AAAAMMDD_HHMMSS.log
```

O log mostra cada perfil mantido, pulado ou apagado, os erros e o espaço liberado no disco.

## Problemas comuns

**"O arquivo não está assinado digitalmente"**
A política de execução do computador foi definida por GPO e exige assinatura para scripts vindos da rede. Copie o script para o disco local antes de executar:

```powershell
Copy-Item "\\servidor\pasta\LimparPerfis.ps1" C:\Windows\Temp\
powershell -File C:\Windows\Temp\LimparPerfis.ps1 -Simular
```

Se a política for `AllSigned`, o script precisa ser assinado pela equipe responsável pelo domínio.

**Unidade de rede (ex.: `P:`) não encontrada**
Unidades mapeadas geralmente não aparecem no PowerShell aberto como Administrador. Use o caminho completo da rede (`\\servidor\pasta`), entre aspas se tiver espaços.


## Licença

MIT
