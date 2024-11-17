{-# LANGUAGE OverloadedStrings #-}

module Main where

import GHC.IO.Encoding as Encoding (setLocaleEncoding, utf8)
import Hakyll
import System.FilePath

configuration :: Configuration
configuration = defaultConfiguration{providerDirectory = "./"}

compiler :: IO ()
compiler = do
  Encoding.setLocaleEncoding Encoding.utf8

  hakyllWith configuration $ do
    match "README.md" $ do
      route (constRoute "index.html")
      compile $
        pandocCompiler
          >>= relativizeUrls

    match "assets/**" $ do
        route idRoute
        compile copyFileCompiler
