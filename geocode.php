<?php
/**
 * Created by PhpStorm.
 * User: BikoP
 * Date: 28/12/2018
 * Time: 16:30
 */

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    $bingKey = "AjXxdnHftTZ_PhefhQrSglEHwq7zLuqunGQhV3qdYpouFfCoZtdU_wiES8Ce4O8m";
    $address = $_GET["address"];
    $key = $_GET["key"];

    if ($key == "e^kf8uxP{9z$1Z") {
        $host = "http://dev.virtualearth.net/REST/v1/Locations";
        $address = $host . "?query=" . urlencode($address) . "&key=" . $bingKey;

        $curl = curl_init();
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt( $curl, CURLOPT_TIMEOUT,2);
        curl_setopt($curl, CURLOPT_URL, $address);

        $result = curl_exec($curl);

        curl_close($curl);

        $result_data = json_decode($result, true);

        $response["latitude"] = $result_data["resourceSets"][0]["resources"][0]["point"]["coordinates"][0];
        $response["longitude"] = $result_data["resourceSets"][0]["resources"][0]["point"]["coordinates"][1];
        echo json_encode($response);
    } else {
        // wrong
        var_dump(http_response_code(403)); // Forbidden access error thrown if password is incorrect

    }

}
