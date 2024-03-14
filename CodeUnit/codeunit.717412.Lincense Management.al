codeunit 71742 "SGA License Management2"
{

    trigger OnRun()
    begin

    end;

    procedure Test()
    var
        Respuesta: text;
    begin
        if Enviar_Mensaje('TEST', '', Respuesta) then
            MESSAGE(Respuesta)
        else
            MESSAGE('Errro Envío: ' + GetLastErrorText());
    end;

    procedure Test_Registro()
    var
        Mensaje: text;
    begin

        Mensaje := '{"Registro":"SEFdb1Vg2OnXJyaHFEgRtxHAWj34du/7oTLxrA7t9uhrVwPGSfT7Kt1qiGk9Od8TP3Sli+u7v77zaUbIUjyFzwv0M/FFEbq7NchK+L0mAkk="}';
        MESSAGE(Registro(Mensaje));
    end;

    procedure Registro(xJson: Text) Respuesta: Text
    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        IAzureFunctionsAuthentication: Interface "Azure Functions Authentication";
        JsonRegistroIn: JsonObject;
        JsonRegistroPoluxOut: JsonObject;
        Encriptado: Text;
        RequestBody: Text;
        CompanyInfo: record "Company Information";
    begin
        If not JsonRegistroIn.ReadFrom(xJson) then EXIT('ERROR Json');

        Get_CompanyInfo(CompanyInfo);

        Encriptado := DatoJsonTexto(JsonRegistroIn, 'Registro');

        JsonRegistroPoluxOut.Add('Licencia_BC', CompanyInfo."License BC");
        JsonRegistroPoluxOut.Add('ID_Polux', CompanyInfo."License Aura-SGA");
        JsonRegistroPoluxOut.Add('Mensaje_App', Encriptado);

        JsonRegistroPoluxOut.WriteTo(RequestBody);

        IAzureFunctionsAuthentication := AzureFunctionsAuthentication.CreateCodeAuth(CompanyInfo."URL API", CompanyInfo."Azure Code");
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(IAzureFunctionsAuthentication, RequestBody, 'application/json');
        if AzureFunctionsResponse.IsSuccessful() then begin
            Message('Post request successful.');
            AzureFunctionsResponse.GetResultAsText(Respuesta);
            Message(Respuesta);
        end
        else
            Error('Post request failed.\Details: %1', AzureFunctionsResponse.GetError());
    end;

    [TryFunction]
    local procedure Enviar_Mensaje(Comando: text; Value: text; var Respuesta: text)
    var
        CompanyInfo: record "Company Information";
        Client: HttpClient;
        Content: HttpContent;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        Url: Text;
        sw9: Boolean;
        Identificador: guid;

    begin
        Respuesta := '';
        sw9 := True;

        Get_CompanyInfo(CompanyInfo);
        Identificador := CreateGuid();

        url := CompanyInfo."URL API" + '?Code=' + CompanyInfo."Azure Code" + '&Command=' + Comando + '&ID=' + format(Identificador);
        if Value <> '' then url += '&Value=' + Value;

        //url := 'https://polux-sga20240312191807.azurewebsites.net/api/Inicio?Command=REGISTRAR&Code=U-RKusNG8dP6CNOvAhwUWDG_dk36RJhPgoYqup3JSlvDAzFudpADYQ==&ID={DE5B33C4-C500-4B75-B0C1-DADB3A0B81B2}&Value={"Licencia_BC":"Polux-Solutions","ID_Polux":"POL#123456","Mensaje_App":"SEFdb1Vg2OnXJyaHFEgRtxHAWj34du/7oTLxrA7t9uhrVwPGSfT7Kt1qiGk9Od8TP3Sli+u7v77zaUbIUjyFzwv0M/FFEbq7NchK+L0mAkk="}';

        SendRequest('POST', url);
    end;

    local procedure SendRequest(HttpMethod: Text[6]; Url: text) ResponseText: Text
    var
        Client: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        RequestHeaders: HttpHeaders;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
    begin

        // This shows how you can set or change HTTP content headers in your request
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'multipart/form-data;boundary=boundary');

        // This shows how you can set HTTP request headers in your request
        HttpRequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');
        RequestHeaders.Add('Accept-Encoding', 'utf-8');
        RequestHeaders.Add('Connection', 'Keep-alive');

        HttpRequestMessage.SetRequestUri(url);
        HttpRequestMessage.Method(HttpMethod);
    end;


    local procedure GetRequest() ResponseText: Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        IsSuccessful: Boolean;
        ServiceCallErr: Label 'Web service call failed.';
        ErrorInfoObject: ErrorInfo;
    begin
        IsSuccessful := Client.Get('https://httpcats.com/418.json', Response);

        if not IsSuccessful then begin
            ErrorInfoObject.DetailedMessage := 'Sorry, we could not retrieve the cat info right now.';
            ErrorInfoObject.Message := ServiceCallErr;
            Error(ErrorInfoObject);
        end;
    end;

    local procedure Get_CompanyInfo(var CompanyInfo: record "Company Information")
    begin
        CompanyInfo.Reset;
        IF not CompanyInfo.findfirst then error('No Existe Información Empresa');
        IF CompanyInfo."License BC" = '' then error('No se ha indicado Licencia BC -Información Empresa');
        IF CompanyInfo."License Aura-SGA" = '' then error('No se ha indicado Licencia Aura-SGA  -Información Empresa');
        IF CompanyInfo."URL API" = '' then error('No se ha definido URL para accesso -Información Empresa-');
        IF CompanyInfo."Azure Code" = '' then error('No se ha definido Azure Code -Información Empresa-');
        IF CompanyInfo."Vector AES" = '' then error('No se ha indicado Vector AES -Información Empresa-');
    end;

    local procedure DatoJsonTexto(xObjeto: JsonObject; xNodo: Text): text
    var
        JsonTokenParte: JsonToken;
        jVariable: Text;
    begin
        jVariable := '';
        if xObjeto.Get(xNodo, JsonTokenParte) then begin
            if JsonTokenParte.AsValue().IsNull then
                exit('')
            else begin
                jVariable := JsonTokenParte.AsValue().AsText();
                exit(jVariable);
            end;
        end else begin
            exit('');
        end;
    end;
}
