param(
    # Só mostra o que seria apagado, sem apagar nada
    [switch]$Simular
)

# ===================== CONFIGURAÇÃO =====================
# Nomes das pastas de perfil que NUNCA serão apagados.
# Aceita curinga: 'adm.*' manteria todos que começam com "adm."
$Manter = @(
    'Administrador',
    'Administrator',
    'Default',
    'Public',
    'defaultuser0',
    # 'sua_conta_local_aqui'
)

$LogPath = "C:\Windows\Temp\LimparPerfis_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
# =======================================================

function Write-Log($msg, $cor = 'White') {
    $linha = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host $linha -ForegroundColor $cor
    Add-Content -Path $LogPath -Value $linha
}

# Precisa rodar como administrador
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
         ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host "Execute o PowerShell como Administrador." -ForegroundColor Red
    exit 1
}

$livreAntes = (Get-PSDrive C).Free

Write-Log "Computador: $env:COMPUTERNAME  |  Modo: $(if ($Simular) {'SIMULAÇÃO'} else {'EXCLUSÃO'})" 'Cyan'

$perfis = Get-CimInstance -ClassName Win32_UserProfile | Where-Object { -not $_.Special }

$apagados = 0; $falhas = 0

foreach ($p in $perfis) {
    $nome = Split-Path $p.LocalPath -Leaf

    # Lista de exceções
    if ($Manter | Where-Object { $nome -like $_ }) {
        Write-Log "MANTIDO   $nome (lista de exceções)" 'DarkGray'
        continue
    }

    # Usuário logado
    if ($p.Loaded) {
        Write-Log "PULADO    $nome (perfil em uso)" 'Yellow'
        continue
    }
    
    if ($Simular) {
        Write-Log "APAGARIA  $nome  ($($p.LocalPath))" 'Magenta'
        continue
    }

    try {
        Remove-CimInstance -InputObject $p -ErrorAction Stop
        Write-Log "APAGADO   $nome" 'Green'
        $apagados++
    } catch {
        Write-Log "ERRO      $nome -> $($_.Exception.Message)" 'Red'
        $falhas++
    }
}

$liberado = [math]::Round(((Get-PSDrive C).Free - $livreAntes) / 1GB, 2)
Write-Log "-----------------------------------------------" 'Cyan'
Write-Log "Apagados: $apagados  |  Falhas: $falhas  |  Espaço liberado: $liberado GB" 'Cyan'
Write-Log "Log salvo em: $LogPath" 'Cyan'

