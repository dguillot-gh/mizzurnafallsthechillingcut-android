# Mizzurna Falls - The Chilling Cut: what the build scripts need to know (dot-sourced by scripts\game-common.ps1).
$Game = 'mizzurnafallsthechillingcut_recomp'
$Package = 'com.psxrecomp.mizzurnafallsthechillingcut'
$Title = 'Mizzurna Falls - The Chilling Cut'
# Supported dumps: the SHA-1 of each disc's data track (the first file its .cue names), in disc order.
$Supported = @(
    @{ Name = 'Mizzurna Falls - The Chilling Cut (SLPS-01783)'
       Sha1 = @('6e6156ef85c9a3bc49da8c21b7118a062e9d9d04') }
)
