<?php
/**
 * Created by PhpStorm.
 * User: BikoP
 * Date: 17/12/2018
 * Time: 22:46
 */

/** This file, when called, retrieves possible addresses in an array from Bing AutoComplete and Foursquare */



$response = array();


if ($_SERVER["REQUEST_METHOD"] == "GET") {
    $query = $_GET["query"];
    $pass = $_GET["pass"];
    $longitude = $_GET['longitude'];
    $latitude = $_GET["latitude"];
    $culture = $_GET["culture"];

    if ($pass == "e^kf8uxP{9z$1Z") {
        $result = get_suggestions($query, $longitude, $latitude, $culture);

        echo $result;

    } else {
        // wrong
        var_dump(http_response_code(403)); // Forbidden access error thrown if password is incorrect

    }
}

function get_suggestions($query, $longitude, $latitude, $culture) {

    $keywords = ["hotel", "cafe", "casino", "restaurant", "bar", "pub", "cinema", "club", "museum", "station",
        "travelodge", "ibis", "novotel", "premier inn", "radisson", "plaza", "carlton", "prestige", "martinez", "kyriad",
        "spa", "majestic", "barriere", "marriott", "campanile", "best western", "okko", "bowling", "fitlane", "carrefour",
        "leclerc", "auchan", "franprix", "polygone", "riviera", "centre", "commercial", "cap", "cinema", "orange", "sephora",
        "dior", "chanel", "théâtre", "theatre", "celio", "swatch", "printemps", "galerie", "lafayette", "kiabi", "renault",
        "citroen", "peugeot", "volkswagen", "volks", "armani", "adagio", "kyriad", "premiere classe", "b&b", "aparthotel",
        "best", "western", "holiday", "fnac", "cultura", "boulanger", "darty", "nike", "tesla", "zara", "burger", "sushi",
        "chinois", "chinese", "mexicain", "mexican", "italian", "italien", "pizza", "pizzeria", "bar", "pub", "hospital",
        "hopital", "port", "gare", "station", "marionnaud", "camaieu", "antibes land", "antibesland", "nice étoile",
        "nice etoile", "staycity", "britannia", "aparthotel", "mercure", "tesco", "asda", "ikea", "john lewis", "sainsburys",
        "sainsbury's", "aquarium", "zoo", "distillery"];


    $isPlace = false;
    foreach($keywords as $substr) {
        if(strpos(strtolower($query), $substr) !== false) {
            $isPlace = true;
        }
    }

    if ($isPlace == false) { // search on Bing
        $host = "http://dev.virtualearth.net/REST/v1/Autosuggest?";
        $subscriptionKey = 'AjXxdnHftTZ_PhefhQrSglEHwq7zLuqunGQhV3qdYpouFfCoZtdU_wiES8Ce4O8m';
        $address = $host . "query=" . urlencode($query) . "&userLocation=" . $latitude . "," . $longitude . ",1000&userRegion=GB&culture=en-GB&countryFilter=GB&key=" . $subscriptionKey;
        $curl = curl_init();


        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt( $curl, CURLOPT_TIMEOUT,2);
        curl_setopt($curl, CURLOPT_URL, $address);

        $result = curl_exec($curl);

        curl_close($curl);

        $result_data = json_decode($result, true);
        $result_processed = $result_data["resourceSets"][0]["resources"][0];
        $result_processed["serviceProvider"] = "Bing";
        $response = json_encode($result_processed, JSON_PRETTY_PRINT);

        return $response;

    } else { // search on Foursquare
        $clientId = "NTYMJWAJDYNGR5WO0TXGUURL45WE3T3PZSEBEDJBKUD5VQSD";
        $client_secret = "XHJLEW253HPHBC0KRATO54WILBP42F031GK2CLIFDCQHHFZ4";
        $host = "https://api.foursquare.com/v2/venues/suggestcompletion?";
        $ll = $latitude . "," . $longitude;
        $arr = array("ll" => $ll, "query" => urlencode($query), "client_id" => $clientId, "client_secret" => $client_secret, "v" => "20190130", "radius" => "5000", "limit" => "10");

        $ch = curl_init();
        $get_string = $host . http_build_query($arr, '', '&');

        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 2);
        curl_setopt($ch, CURLOPT_URL, $get_string);

        $result = curl_exec($ch);
        curl_close($ch);

        $result_data = json_decode($result, true);
        $result_processed = $result_data["response"]["minivenues"];
        $result_processed["serviceProvider"] = "Foursquare";

        $response = json_encode($result_processed, JSON_PRETTY_PRINT);

        return $response;
    }


}

?>