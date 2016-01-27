{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Arrows #-}
{-# LANGUAGE DeriveGeneric #-}

-- | Interface for the RNAcentral REST webservice.
--   
module Bio.RNAcentralHTTP (rnaCentralHTTP,
                      buildSequenceViaMD5Query,
                      getRNACentralEntries,
                      showRNAcentralAlienEvaluation,
                      RNAcentralEntryResponse,
                      RNAcentralEntry
                      ) where

import Network.HTTP.Conduit    
import qualified Data.ByteString.Lazy.Char8 as L8    
import Network
import Control.Concurrent
import Data.Text
import Data.Aeson
import GHC.Generics
import qualified Data.Digest.Pure.MD5 as M
import Bio.Core.Sequence 
import Bio.Sequence.Fasta
import Data.Either
import Data.Aeson.Types

--Datatypes
-- | Data structure for RNAcentral entry response
data RNAcentralEntryResponse = RNAcentralEntryResponse
  {
    count :: Int,
    next :: Maybe Text,
    previous :: Maybe Text,
    results :: [RNAcentralEntry]
  }
  deriving (Show, Eq, Generic)

instance ToJSON RNAcentralEntryResponse where
  toJSON = genericToJSON defaultOptions
  --toEncoding = genericToEncoding defaultOptions

instance FromJSON RNAcentralEntryResponse 

data RNAcentralEntry = RNAcentralEntry
  {
    url :: Text,
    rnacentral_id :: Text,
    md5 :: Text,
    sequence :: Text,
    length :: Int,
    xrefs :: Text,
    publications :: Text
  }
  deriving (Show, Eq, Generic)

instance ToJSON RNAcentralEntry where
  toJSON = genericToJSON defaultOptions
  --toEncoding = genericToEncoding defaultOptions

instance FromJSON RNAcentralEntry 

-- | Send query and parse return XML 
startSession :: String -> IO (Either String RNAcentralEntryResponse)
startSession query' = do
  requestXml <- withSocketsDo
      $ sendQuery query'
  let eitherErrorResponse = eitherDecode requestXml :: Either String RNAcentralEntryResponse
  return eitherErrorResponse
  
-- | Send query and return response XML
sendQuery :: String -> IO L8.ByteString
sendQuery query' = simpleHttp ("http://rnacentral.org/api/v1/rna/" ++ query')

-- | Function for querying the RNAcentral REST interface.
rnaCentralHTTP :: String -> IO (Either String RNAcentralEntryResponse)
rnaCentralHTTP query' = do
  startSession query'

-- | Function for delayed queries to the RNAcentral REST interface. Enforces the maximum 20 requests per second policy.
delayedRNACentralHTTP :: String -> IO (Either String RNAcentralEntryResponse)
delayedRNACentralHTTP query' = do
  threadDelay 55000
  startSession query'

getRNACentralEntries :: [String] -> IO [(Either String RNAcentralEntryResponse)]
getRNACentralEntries queries = do
  responses <- mapM delayedRNACentralHTTP queries
  return responses

buildSequenceViaMD5Query :: Sequence -> String
buildSequenceViaMD5Query s = qString
  where querySequence = unSD (seqdata s)
        querySequenceUreplacedwithT = L8.map bsreplaceUT querySequence
        md5Sequence = M.md5 querySequenceUreplacedwithT
        qString = "?md5=" ++ (show md5Sequence)

showRNAcentralAlienEvaluation :: [(Either String RNAcentralEntryResponse)] -> String
showRNAcentralAlienEvaluation responses = output
  where resultEntries = Prelude.concatMap results (rights responses)
        resulthead = "Sequences found by RNAlien with RNAcentral entry:\nrnacentral_id\tmd5\tlength\n"
        resultentries = Prelude.concatMap showRNAcentralAlienEvaluationLine resultEntries
        output = if resultentries == [] then resulthead ++ "No matching sequences found in RNAcentral\n" else resulthead ++ resultentries
        
showRNAcentralAlienEvaluationLine :: RNAcentralEntry -> String
showRNAcentralAlienEvaluationLine entry = unpack (rnacentral_id entry) ++ "\t" ++ unpack (md5 entry) ++ "\t" ++ show (Bio.RNAcentralHTTP.length entry) ++"\n"

bsreplaceUT :: Char -> Char
bsreplaceUT a
  | a == 'U' = 'T'
  | otherwise = a