# Prueba de interfaz en Windows: arranca BookApp, pulsa los controles y guarda
# capturas y la lista de controles en shots/.
# Los textos son controles Static (se buscan por texto); los botones con estilo
# los dibuja SwiftOpenUI (Direct2D). La ventana se coloca siempre en (0,0) con 900x700.
. "$PSScriptRoot/ui.ps1"
$bin = swift build --product BookApp --show-bin-path

function Count-Text([string]$text) { @(Get-Controls $w | Where-Object { $_.Text -eq $text }).Count }
function Count-Like([string]$pattern) { @(Get-Controls $w | Where-Object { $_.Text -like $pattern }).Count }

# Clic en el botón de estado de una fila: el botón pequeño (24 px) a la izquierda del título.
function Click-Toggle([string]$title) {
    $c = Get-Controls $w | Where-Object { $_.Text -eq $title } | Select-Object -First 1
    if (-not $c) { throw "No hay una fila '$title'" }
    $b = Get-Controls $w | Where-Object { $_.Class -eq "SwiftUICustomButton" -and $_.W -le 32 -and $_.X -lt $c.X } |
        Sort-Object { [math]::Abs(($_.Y + $_.H / 2) - ($c.Y + $c.H / 2)) } | Select-Object -First 1
    if (-not $b) { throw "No hay boton de estado junto a '$title'" }
    Click-At ($b.X + [int]($b.W / 2)) ($b.Y + [int]($b.H / 2))
}

# Clic en una opcion de la barra lateral: el texto mas a la izquierda con ese nombre.
function Click-Sidebar([string]$text) {
    $c = Get-Controls $w | Where-Object { $_.Text -eq $text -or $_.Text -like "* $text" } |
        Sort-Object X | Select-Object -First 1
    if (-not $c) { return $false }
    Click-At ($c.X + [int]($c.W / 2)) ($c.Y + [int]($c.H / 2))
    return $true
}

$app = Start-App "$bin\BookApp.exe" "bookapp"
if ($app.HasExited) { throw "La app se ha cerrado al arrancar" }
$w = Get-AppWindow $app.Id
Snap $w "1-inicio"
if ((Count-Text "Don Quijote de la Mancha") -ne 1) { throw "No se ve la lista de libros" }

# Cambiar estado desde la fila no debe abrir el detalle.
Click-Toggle "1984"; Snap $w "2-1984-estado-cambiado"
if ((Count-Text "1984") -ne 1) { throw "Al cambiar estado la fila se ha salido de la lista" }

# Detalle: escribir no debe volver a la lista (fallo de SwiftOpenUI con @Observable, ya arreglado).
if (-not (Click-Text $w "Cien anos de soledad")) { throw "No esta la fila Cien anos de soledad" }
Snap $w "3-detalle"
if (-not (Click-Class $w "Edit")) { throw "El detalle no tiene campo de titulo" }
Send-Text "{END} (edicion)"; Snap $w "4-detalle-editado"
if (-not (Click-Class $w "Edit")) { throw "Al escribir se ha salido del detalle" }
if (-not (Click-Text $w "Back")) { if (-not (Click-Text $w "<- Back")) { throw "No hay boton para volver" } }
Snap $w "5-lista-tras-volver"
if ((Count-Text "Cien anos de soledad (edicion)") -ne 1) { throw "La lista no muestra el titulo editado" }

# Ajustes: activar F1 (Progreso) y volver a Libros.
if (-not (Click-Sidebar "Ajustes")) { throw "No esta Ajustes en la barra lateral" }
Snap $w "6-ajustes"
if (-not (Click-Text $w "F1: Mostrar progreso de lectura")) { throw "No esta el toggle de Progreso en Ajustes" }
Snap $w "7-progreso-activado"
if (-not (Click-Sidebar "Libros")) { throw "No esta Libros en la barra lateral" }
Snap $w "8-libros-con-progreso"

# Al volver a abrir se conservan los libros y los ajustes.
Stop-Process -Id $app.Id -Force; Start-Sleep -Seconds 2
$app = Start-App "$bin\BookApp.exe" "bookapp2"
if ($app.HasExited) { throw "La app se ha cerrado al volver a abrirla" }
$w = Get-AppWindow $app.Id
Snap $w "9-tras-reiniciar"
if ((Count-Text "Cien anos de soledad (edicion)") -ne 1) { throw "No se ha conservado el titulo editado" }

Stop-Process -Id $app.Id -Force
Write-Host "Prueba de Windows superada"
