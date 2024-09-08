using GNNCellTypeClassifier
using Documenter

DocMeta.setdocmeta!(GNNCellTypeClassifier, :DocTestSetup, :(using GNNCellTypeClassifier); recursive=true)

makedocs(;
    modules=[GNNCellTypeClassifier],
    authors="Chris Damour",
    sitename="GNNCellTypeClassifier.jl",
    format=Documenter.HTML(;
        canonical="https://damourChris.github.io/GNNCellTypeClassifier.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/damourChris/GNNCellTypeClassifier.jl",
    devbranch="main",
)
