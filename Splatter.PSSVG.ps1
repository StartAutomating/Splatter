#requires -Module PSSVG
   
$psChevron = 
    svg.symbol -Id psChevron -Content @(
        svg.polygon -Points (@(
            "40,20"
            "45,20"
            "60,50"
            "35,80"
            "32.5,80"
            "55,50"
        ) -join ' ')
    ) -ViewBox 100, 100 -PreserveAspectRatio $false

$assetsPath = Join-Path $PSScriptRoot Assets

if (-not (Test-Path $assetsPath)) {
    $null = New-item -ItemType Directory -Path $assetsPath
}

$FontName = 'Dancing Script'
svg -ViewBox 300, 100 @(
    $psChevron
    svg.use -Href '#psChevron' -Fill '#b00707' -Height 5% -Y 47% -X -1.5% 
    SVG.GoogleFont -FontName $FontName
    
    svg.text -X 50% -Y 50% -TextAnchor 'middle' -DominantBaseline 'middle' -Style "font-family: '$FontName', sans-serif" -Fill '#b00707' -Class 'foreground-fill' -Content @(
        SVG.tspan -FontSize .5em -Content 'spl@tter'
        # SVG.tspan -FontSize 1em -Content 'git' -Dx -.25em
    ) -FontSize 4em -FontWeight 500
) -OutputPath (Join-Path $assetsPath Splatter.svg)

svg -ViewBox 1920, 1080 @(
    $psChevron
    svg.use -Href '#psChevron' -Fill '#b00707' -Height 10% -Y 43% -X -5% 
    SVG.GoogleFont -FontName $FontName
    
    svg.text -X 50% -Y 50% -TextAnchor 'middle' -DominantBaseline 'middle' -Style "font-family: '$FontName', sans-serif" -Fill '#b00707' -Class 'foreground-fill' -Content @(
        SVG.tspan -FontSize .5em -Content 'spl@tter'
        # SVG.tspan -FontSize 1em -Content 'git' -Dx -.25em
    ) -FontSize 90em -FontWeight 500
) -OutputPath (Join-Path $assetsPath 'Splatter@1080p.svg')


$AnimationTimeframe = [Ordered]@{
    Dur = '2s'
    RepeatCount = 'indefinite'
}

svg -ViewBox 1920, 1080 @(
    $psChevron
    svg.use -Href '#psChevron' -Fill '#b00707' -Height 10% -Y 43% -X -5% 
    SVG.GoogleFont -FontName $FontName
             
    svg.text -X 50% -Y 50% -TextAnchor 'middle' -DominantBaseline 'middle' -Style "font-family: '$FontName', sans-serif; " -Fill '#b00707' -Class 'foreground-fill' -Content @(
        SVG.tspan -FontSize .5em -Content 'spl@tter'
        # SVG.tspan -FontSize 1em -Content 'git' -Dx -.25em
        SVG.animate -AttributeName fill -dur 10s -Values '#b00707;#b01707;#ed2222;#b01707;#b00707' -RepeatCount indefinite
    ) -FontSize 90em -FontWeight 500
) -OutputPath (Join-Path $assetsPath 'Splatter@1080p-Animated.svg')

