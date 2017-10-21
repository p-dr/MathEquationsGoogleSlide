port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, onClick)
import String
import Basics exposing (..)
import List exposing (..)

{-
Example latex 
\(x^2 + y^2 = z^2\)

Ports
https://hackernoon.com/how-elm-ports-work-with-a-picture-just-one-25144ba43cdd
https://guide.elm-lang.org/interop/javascript.html

First convert elm to js
- elm-make SelectInput.elm --output=SelectInput.js

Second change extension to html

-}
port reloadEquaion : String -> Cmd msg
port updateEquaion : String -> Cmd msg
port sumitEquation : String -> Cmd msg
port toElm : (String -> msg) -> Sub msg

main =
  Html.program
    { view = view
    , update = update
    , init = init
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init  =
  ( Model MathML "df", Cmd.none
  )



-- MODEL


type alias Model =
  { mathType: MathType,
    linkedMathEquation: String
  }

type  MathType =
         MathML
        | Latex
        | Tex

valuesWithLabels : List ( MathType, String )
valuesWithLabels =
  [ ( MathML, "MathML" )
  , ( Latex, "Latex" )
  , ( Tex, "Tex" )
  ]

-- often this can be replaced with `toString`
toOptionString : MathType -> String
toOptionString currency =
  case currency of
    MathML -> "MathML"
    Latex -> "Latex"
    Tex -> "Tex"

fromOptionString : String -> MathType
fromOptionString string =
  case string of
    "MathML" -> MathML
    "Latex" -> Latex
    "Tex" -> Tex
    _ -> Tex



viewOption : MathType -> Html Msg
viewOption mathType =
  option
    [ value <| toString mathType ]
    [ text <| toString mathType ]


{--------------Update----------------------------------------}
type Msg
  = MathTypeChange String
  | ReloadEquaion 
  | SumitEquation
  | UpdateStr String
  | SetLinkedMathEquation String
  | UpdateEquaion String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MathTypeChange newMathType ->
      ({ model | mathType =  fromOptionString newMathType }, Cmd.none)
    
    -- event to reload the id
    ReloadEquaion ->
        ( model, reloadEquaion "reload")

    -- event to submit equaion
    SumitEquation ->
        ( model, sumitEquation model.linkedMathEquation)
    
    -- event to send string
    -- update
    UpdateEquaion str-> 
        ( model, updateEquaion str)
    
    UpdateStr  str ->
        (model, Cmd.none)

    SetLinkedMathEquation str ->
        ({ model | linkedMathEquation =  str}, Cmd.none)

-- VIEW
{--------------HTML----------------------------------------}
view : Model -> Html Msg
view model =
  div []
    [ 
     infoHeader,
     select
        [ onInput MathTypeChange, id "selectMathType"
        ]
        [ viewOption MathML
        , viewOption Latex
        , viewOption Tex
        ],
     textarea [id "textAreaMathEquation", placeholder "get changed", onInput UpdateEquaion ] [],
     button [id "submitMathEquation", onClick SumitEquation] [text "submit"] , 
     --button [ onClick (SendToJs "testing")] [text "send Info"],
     div [ id "reloadContainer"] [
        button [onClick ReloadEquaion ] [text "reload"],
        button [onClick (SetLinkedMathEquation ""), hidden (String.isEmpty model.linkedMathEquation)] [text "unconnect"]
     ],
     p [id "MathTextElm"] [text "The answer you provided is: ${}$."],
     infoFooter
    ]



infoHeader : Html msg
infoHeader = 
    header []
           [h1 [] [text "Math"],
            h1 [] [text "Equations"] ]

infoFooter : Html msg
infoFooter =
    footer [ class "info" ]
        [ p [] [ text " Stuff " ]
        , p []
            [ text "Written by "
            , a [ href "https://github.com/evancz" ] [ text "Evan Czaplicki" ]
            ]
        , p []
            [ text "Part of "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]
{--------------HTML----------------------------------------}

{--------------SubScriptions----------------------------------------}
subscriptions : Model -> Sub Msg
subscriptions model =
  toElm UpdateStr

{-----------end-SubScriptions----------------------------------------}