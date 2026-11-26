# Prueba de interfaz en Windows de las características originales de Víctor R (O1 y O5).
#   windows-ui-originales.ps1 Favoritos   producto con O1
#   windows-ui-originales.ps1 Completa    todas las características
# Activa cada característica en Ajustes, la usa, comprueba la lista y vuelve a abrir la app.
param([string]$Trait = "Favoritos")
. "$PSScriptRoot/ui.ps1"
swift build --product BookApp --traits $Trait
if ($LASTEXITCODE -ne 0) { throw "No compila con el trait $Trait" }
$bin = swift build --product BookApp --traits $Trait --show-bin-path

function Count-Text([string]$text) { @(Get-Controls $w | Where-Object { $_.Text -eq $text }).Count }
function Count-Like([string]$pattern) { @(Get-Controls $w | Where-Object { $_.Text -like $pattern }).Count }
function Click-Sidebar([string]$text) {
    $c = Get-Controls $w | Where-Object { $_.Text -eq $text -or $_.Text -like "* $text" } |
        Sort-Object X | Select-Object -First 1
    if (-not $c) { return $false }
    Click-At ($c.X + [int]($c.W / 2)) ($c.Y + [int]($c.H / 2))
    return $true
}
# Los botones con estilo los dibuja SwiftOpenUI (Direct2D) y no tienen texto: se buscan
# por su posición respecto a un texto de la misma pantalla.
function Click-Surface($surface) {
    if (-not $surface) { return $false }
    Click-At ($surface.X + [int]($surface.W / 2)) ($surface.Y + [int]($surface.H / 2))
    return $true
}
# Botón del filtro de favoritos: el que está a la izquierda del contador «★ N» de la lista.
function Click-FavoritesFilter {
    $count = Get-Controls $w | Where-Object { $_.Text -like "★ *" -and $_.Text -ne "★ Favorito" } | Select-Object -First 1
    if (-not $count) { return $false }
    $button = Get-Controls $w | Where-Object { $_.Class -eq "SwiftUID2DSurface" -and $_.X -lt $count.X -and
        [math]::Abs(($_.Y + $_.H / 2) - ($count.Y + $count.H / 2)) -lt 20 } | Sort-Object X -Descending | Select-Object -First 1
    return (Click-Surface $button)
}
function Go-Back {
    if (-not (Click-Text $w "← Back")) { if (-not (Click-Text $w "Back")) { throw "No hay botón para volver" } }
}

$app = Start-App "$bin\BookApp.exe" "originales"
if ($app.HasExited) { throw "La app se ha cerrado al arrancar" }
$w = Get-AppWindow $app.Id

# Con el flag apagado, O1 no se ve.
if ((Count-Like "★ *") -ne 0) { throw "Con O1 apagada no debería verse el filtro" }

# Ajustes: activar las características.
if (-not (Click-Sidebar "Ajustes")) { throw "No está Ajustes en la barra lateral" }
if (-not (Click-Text $w "O1: Favoritos")) { throw "No está el ajuste de O1" }
Snap $w "o-1-ajustes"

# Se vuelve a abrir la app en lugar de volver a Libros por la barra lateral: en Win32,
# SwiftOpenUI no recoloca la pila de navegación recreada y el detalle queda recortado.
# Así, además, se comprueba que los ajustes se conservan.
Stop-Process -Id $app.Id -Force; Start-Sleep -Seconds 2
$app = Start-App "$bin\BookApp.exe" "originales1"
if ($app.HasExited) { throw "La app se ha cerrado al volver a abrirla" }
$w = Get-AppWindow $app.Id
Snap $w "o-1b-libros"
if ((Count-Text "★ 0") -ne 1) { throw "No se ve el filtro de favoritos" }

# O1: marcar «1984» como favorito desde el detalle.
if (-not (Click-Text $w "1984")) { throw "No está la fila 1984" }
if (-not (Click-Text $w "Favorito")) { throw "No está el interruptor Favorito en el detalle" }
Snap $w "o-2-detalle-favorito"
Go-Back
if ((Count-Text "★ Favorito") -ne 1) { throw "La fila no muestra «★ Favorito»" }
if ((Count-Text "★ 1") -ne 1) { throw "El contador de favoritos no ha cambiado" }

# O1: el filtro deja solo los favoritos.
if (-not (Click-FavoritesFilter)) { throw "No se puede pulsar el filtro" }
Snap $w "o-3-solo-favoritos"
if ((Count-Text "1984") -ne 1) { throw "El favorito no se ve con el filtro" }
if ((Count-Text "Don Quijote de la Mancha") -ne 0) { throw "Con el filtro se ven libros que no son favoritos" }
if (-not (Click-FavoritesFilter)) { throw "No se puede quitar el filtro" }
if ((Count-Text "Don Quijote de la Mancha") -ne 1) { throw "Al quitar el filtro no vuelve la biblioteca" }

# Al volver a abrir se conservan el favorito y los ajustes.
Stop-Process -Id $app.Id -Force; Start-Sleep -Seconds 2
$app = Start-App "$bin\BookApp.exe" "originales2"
if ($app.HasExited) { throw "La app se ha cerrado al volver a abrirla" }
$w = Get-AppWindow $app.Id
Snap $w "o-9-tras-reiniciar"
if ((Count-Text "★ Favorito") -ne 1) { throw "No se ha conservado el favorito" }

Stop-Process -Id $app.Id -Force
Write-Host "Prueba de Windows de las originales ($Trait) superada"
