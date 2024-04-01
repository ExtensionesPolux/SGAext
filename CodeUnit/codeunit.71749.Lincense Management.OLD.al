codeunit 71749 "SGA License Management OLD"
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



    procedure MOTD(xJson: text) Respuesta: Text
    var
        JsonMOTDIn: JsonObject;
    begin
        If not JsonMOTDIn.ReadFrom(xJson) then EXIT(lblErrorJson);
    end;


    procedure Vector_AES() Respuesta: text
    var
        CompanyInfo: Record "Company Information";
        JsonObjectRecurso: JsonObject;
        JsonText: Text;
    begin
        Get_CompanyInfo(CompanyInfo);


        Respuesta := CompanyInfo."Vector AES";

        JsonObjectRecurso.Add('Vector', CompanyInfo."Vector AES");
        JsonObjectRecurso.WriteTo(JsonText);
        exit(JsonText);
    end;


    procedure Registro(xJson: Text) Respuesta: Text
    var
        JsonRegistroIn: JsonObject;
        JsonRegistroOut: JsonObject;
        JsonRegistroPoluxOut: JsonObject;
        JsonRegistroPoluxIn: JsonObject;
        JsonAzure: JsonObject;
        CompanyInfo: record "Company Information";
        Encriptado: text;
        json: text;
    begin
        If not JsonRegistroIn.ReadFrom(xJson) then EXIT(lblErrorJson);

        Get_CompanyInfo(CompanyInfo);

        Encriptado := DatoJsonTexto(JsonRegistroIn, 'Registro');

        JsonRegistroPoluxOut.Add('Licencia_BC', CompanyInfo."License BC");
        JsonRegistroPoluxOut.Add('ID_Polux', CompanyInfo."License Aura-SGA");
        JsonRegistroPoluxOut.Add('Mensaje_App', Encriptado);

        JsonRegistroPoluxOut.WriteTo(json);

        if NOT Enviar_Mensaje('REGISTRAR', json, Respuesta) then Error('Error Envío mensaje: ' + GetLastErrorText());

        If not JsonAzure.ReadFrom(Respuesta) then EXIT(lblErrorJson);
        IF CompanyInfo."License BC" <> DatoJsonTexto(JsonAzure, 'Licencia_BC') then error('Mensaje Recibido con destinatario incorrecto');
        IF CompanyInfo."License Aura-SGA" <> DatoJsonTexto(JsonAzure, 'ID_Polux') then error('Mensaje Recibido con ID Aura incorrecto');

        Respuesta := DatoJsonTexto(JsonAzure, 'Mensaje_App');
    end;




    #Region Funciones Auxiliares

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

    [TryFunction]
    local procedure Enviar_Mensaje(Comando: text; Value: text; var Respuesta: text)
    var
        CompanyInfo: record "Company Information";
        Client: HttpClient;
        Content: HttpContent;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        InStream: InStream;
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
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
        sw9 := client.Post(Url, Content, ResponseMessage);
        IF sw9 then sw9 := ResponseMessage.IsSuccessStatusCode();

        if sw9 then sw9 := ResponseMessage.Content().ReadAs(InStream);
        if sw9 then sw9 := JObject.ReadFrom(InStream);


        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        OutStream.WriteText(Respuesta);

        if sw9 then JObject.WriteTo(Respuesta);
    end;

    [TryFunction]
    procedure CreateRequest_POST(RequestUrl: Text; json: Text; var Respuesta: text)
    var
        TempBlob: Codeunit "Temp Blob";
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        ResponseHeader: HttpResponseMessage;
        MailContentHeaders: HttpHeaders;
        Content: HttpContent;
        HttpHeadersContent: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        JObject: JsonObject;
        ResponseStream: InStream;
        APICallResponseMessage: Text;
        StatusCode: Text;
        IsSuccessful: Boolean;

        JsonObjectRespuesta: JsonObject;
        TokenJson: JsonToken;
    begin
        //BODY
        Respuesta := '';

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Clear();

        Content.WriteFrom(json);

        //GET HEADERS
        Content.GetHeaders(HttpHeadersContent);
        HttpHeadersContent.Clear();
        HttpHeadersContent.Remove('Content-Type');
        HttpHeadersContent.Add('Content-Type', 'application/json');

        //POST METHOD
        RequestMessage.Content := Content;
        RequestMessage.SetRequestUri(RequestUrl);
        RequestMessage.Method := 'POST';

        Clear(TempBlob);
        TempBlob.CreateInStream(ResponseStream);

        IsSuccessful := Client.Send(RequestMessage, ResponseMessage);

        if not IsSuccessful then error('An API call with the provided header has failed.');
        if not ResponseMessage.IsSuccessStatusCode() then begin
            StatusCode := Format(ResponseMessage.HttpStatusCode()) + ' - ' + ResponseMessage.ReasonPhrase;
            error('The request has failed with status code ' + StatusCode);
        end;

        if not ResponseMessage.Content().ReadAs(ResponseStream) then error('The response message cannot be processed.');
        if not JObject.ReadFrom(ResponseStream) then error('Cannot read JSON response.');

        //API response
        JObject.WriteTo(APICallResponseMessage);

        Respuesta := APICallResponseMessage;

        //APICallResponseMessage := APICallResponseMessage.Replace(',', '\');

        if JsonObjectRespuesta.ReadFrom(APICallResponseMessage) then begin
            if JsonObjectRespuesta.Get('detail', TokenJson) then begin
                Respuesta := TokenJson.AsValue().AsText();
            end;
        end;
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
    #endregion



    var
        lblErrorJson: Label 'Incorrect format. A Json was expected', Comment = 'ESP=Formato incorrecto. Se esperaba un Json';
}