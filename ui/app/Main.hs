{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

import Brick
import Brick.Widgets.List
import Control.Monad (void)
import Control.Monad.IO.Class (liftIO)
import Control.Lens ((^.))
import Numeric (showHex)
import System.Environment (getArgs)
import System.Hardware.Serialport (SerialPort, openSerial, closeSerial, defaultSerialSettings, send, SerialPortSettings(commSpeed), CommSpeed(..))

import qualified Data.ByteString.Char8 as BS
import qualified Brick.Widgets.Center as C
import qualified Data.Vector as Vec
import qualified Graphics.Vty as V

main :: IO ()
main = do
    portPath <- getArgs >>= \case
        [sPort] ->
            return sPort
        _ ->
            error "Expected Usage: ./control.hs /dev/ttyUSB0\n"
    serialPort <- openSerial portPath defaultSerialSettings { commSpeed = CS19200 }
    let state = initial serialPort
    void $ defaultMain app state
    closeSerial serialPort


data AppState
    = AppState
        { appRed :: List AppWidget Int
        , appGreen :: List AppWidget Int
        , appBlue :: List AppWidget Int
        , selectedList :: AppWidget
        , appSerial :: SerialPort
        }

initial :: SerialPort -> AppState
initial sp =
    AppState
        { appRed = colorList RedList
        , appGreen = colorList GreenList
        , appBlue = colorList BlueList
        , selectedList = RedList
        , appSerial = sp
        }
    where
        colorList n =
            list n (Vec.fromList [0 .. 255]) 1

data AppWidget
    = RedList
    | GreenList
    | BlueList
    deriving (Show, Eq, Ord)

app :: App AppState e AppWidget
app =
    App
        { appDraw = draw
        , appChooseCursor = showCursorNamed . selectedList
        , appHandleEvent = handleEvent
        , appStartEvent = return
        , appAttrMap = styles
        }

styles :: AppState -> AttrMap
styles _ =
    attrMap V.defAttr
        [ ( listSelectedAttr, V.black `on` V.white )
        , ( listSelectedFocusedAttr, V.white `on` V.magenta )
        ]


draw :: AppState -> [Widget AppWidget]
draw s@AppState {appRed, appGreen, appBlue, selectedList} =
    [ C.center $ vBox
        [ hBox [ str $ "  #" ++ BS.unpack (getHexString s) ]
        , hBox [ txt " R   G   B " ]
        , vLimit 20 $ hBox
            [ hLimit 3 $ drawList appRed
            , txt " "
            , hLimit 3 $ drawList appGreen
            , txt " "
            , hLimit 3 $ drawList appBlue
            ]
        ]
    ]
    where
        drawList l =
            renderList (\_ i -> C.hCenter . str $ show i)
                (selectedList == l ^. listNameL) l



handleEvent :: AppState -> BrickEvent AppWidget e -> EventM AppWidget (Next AppState)
handleEvent s = \case
    VtyEvent (V.EvKey (V.KChar 'q') []) ->
        halt s
    VtyEvent (V.EvKey V.KEnter []) ->
        continue s
            { selectedList = case selectedList s of
                RedList ->
                    GreenList
                GreenList ->
                    BlueList
                BlueList ->
                    RedList
            }
    VtyEvent ev -> do
        newState <- case selectedList s of
            RedList -> do
                newList <- handleListEvent ev (appRed s)
                return s { appRed = newList }
            GreenList -> do
                newList <- handleListEvent ev (appGreen s)
                return s { appGreen = newList }
            BlueList -> do
                newList <- handleListEvent ev (appBlue s)
                return s { appBlue = newList }
        liftIO $ sendColor newState
        continue newState
    _ ->
        continue s

sendColor :: AppState -> IO ()
sendColor s =
    void $ send (appSerial s) $ getHexString s

getHexString :: AppState -> BS.ByteString
getHexString AppState { appRed, appGreen, appBlue } =
    BS.pack $ concatMap getHex [appRed, appGreen, appBlue]
    where
        getHex l =
            let
                selected =
                    maybe 0 snd $ listSelectedElement l
                fromInt =
                    showHex selected ""
            in
                if selected < 16 then
                    "0" <> fromInt
                else
                    fromInt
