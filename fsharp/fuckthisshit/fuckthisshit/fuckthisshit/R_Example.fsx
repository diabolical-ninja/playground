#I "../packages/RProvider.1.1.20"
#load "RProvider.fsx"


open System
open RDotNet
open RProvider
open RProvider.graphics
open RProvider.stats
open RProvider.rpart




// Random number generator
let rng = Random()
let rand () = rng.NextDouble()

// Generate fake X1 and X2 
let num_obs = 100

let X1s = [ for i in 0 .. num_obs -> 10. * rand () ]
let X2s = [ for i in 0 .. num_obs -> 5. * rand () ]

// Build Ys, following the "true" model
let Ys = [ for i in 0 .. num_obs -> 5. + 3. * X1s.[i] - 2. * X2s.[i] + rand () ]




let dataset =
    namedParams [
        "Y", box Ys;
        "X1", box X1s;
        "X2", box X2s; ]
    |> R.data_frame


let result = R.rpart(formula = "Y~X1+X2", data = dataset)

let summary = R.summary(result)

R.plot result