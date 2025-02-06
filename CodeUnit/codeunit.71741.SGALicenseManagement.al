codeunit 71741 "SGA License Management"
{

    trigger OnRun()
    begin

    end;

    #region Funciones

    procedure Vector_AES() Respuesta: Text
    var
        CompanyInfo: record "Company Information";
    begin
        Get_CompanyInfo(CompanyInfo);

        Respuesta := CompanyInfo."Vector AES";
    end;


    procedure MOTD(DispositivoId: code[20]) Mensaje: Text
    var
        RecordLinkMgt: Codeunit "Record Link Management";
        CompanyInfo: record "Company Information";
        Dispositivo: record Dispositivos;
        RecordLink: record "Record Link";
        jsonMOTD: JsonObject;
        jsonArray: JsonArray;
        jsonTexto: JsonObject;
        textoJson: text;
        NoteText: BigText;
        Stream: InStream;
    begin
        Get_CompanyInfo(CompanyInfo);


        jsonMOTD.add('Id_Dispositivo', DispositivoId);
        jsonMOTD.Add('Estado', 'OK');
        jsonMOTD.add('Mensaje_Error', '');

        Dispositivo.Reset;
        Dispositivo.SetRange(Code, DispositivoId);
        IF Dispositivo.Findfirst then begin
            IF Dispositivo.Baja then
                jsonMOTD.add('Baja', 'True')
            else begin
                RecordLink.Reset;
                RecordLink.SetRange("Record ID", Dispositivo.RecordId);
                RecordLink.SetRange(Type, RecordLink.Type::Note);
                IF RecordLink.Findset(false) then
                    repeat
                        RecordLink.CalcFields(Note);
                        IF RecordLink.Note.HasValue then begin

                            CLEAR(NoteText);
                            RecordLink.Note.CREATEINSTREAM(Stream);
                            NoteText.READ(Stream);
                            NoteText.GETSUBTEXT(NoteText, 2);

                            CLEAR(jsonTexto);
                            jsonTexto.add('Mensaje', FORMAT(NoteText));
                            jsonArray.Add(jsonTexto);
                        end;
                    until RecordLink.NEXT = 0;
            end;
        end;
        textoJson := '';
        IF jsonArray.Count > 0 then jsonArray.WriteTo(textojson);
        if textoJson = '[]' then textojson := '';
        //jsonMOTD.add('MOTD', textoJson);
        jsonMOTD.add('MOTD', jsonArray);

        jsonMOTD.WriteTo(Mensaje);
    end;



    procedure Hola() Respuesta: Text
    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        IAzureFunctionsAuthentication: Interface "Azure Functions Authentication";
        JsonAzure: JsonObject;
        jsonEntrada: JsonObject;
        RespuestaAzure: text;
        RequestBody: text;
        CompanyInfo: record "Company Information";
        Identificador: Guid;
    begin
        Get_CompanyInfo(CompanyInfo);
        Identificador := CreateGuid();

        JsonAzure.add('Commando', 'HOLA');
        JsonAzure.Add('ID', Identificador);
        JsonAzure.Add('CompanyName', CompanyName);
        JsonAzure.WriteTo(RequestBody);

        IAzureFunctionsAuthentication := AzureFunctionsAuthentication.CreateCodeAuth(CompanyInfo."URL API", CompanyInfo."Azure Code");
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(IAzureFunctionsAuthentication, RequestBody, 'application/json');
        if AzureFunctionsResponse.IsSuccessful() then begin
            AzureFunctionsResponse.GetResultAsText(RespuestaAzure);
            JsonEntrada.ReadFrom(RespuestaAzure);
            Respuesta := DatoJsonTexto(jsonEntrada, 'Mensaje_Salida');
        end
        else
            Error('Post request failed.\Details: %1', AzureFunctionsResponse.GetError());
    end;


    local procedure EsSandBox(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";

    begin
        exit(EnvironmentInformation.IsSandbox());
    end;

    local procedure EsOnPremise(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";

    begin
        exit(EnvironmentInformation.IsOnPrem());
    end;

    procedure Registro(xJson: Text) Respuesta: Text
    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        IAzureFunctionsAuthentication: Interface "Azure Functions Authentication";
        Dispositivos: record Dispositivos;
        Id_Dispositivo: code[40];
        jsonEntrada: JsonObject;
        JsonBC: JsonObject;
        JsonAzure: JsonObject;
        Encriptado: Text;
        MensajeBC: Text;
        RespuestaAzure: text;
        RequestBody: text;
        CompanyInfo: record "Company Information";
        Identificador: Guid;

    begin
        Get_CompanyInfo(CompanyInfo);
        Identificador := CreateGuid();

        Encriptado := xJson;

        JsonBC.Add('Licencia_BC', CompanyInfo."License BC");
        JsonBC.Add('Id_Polux', CompanyInfo."License Aura-SGA");
        JsonBC.Add('CompanyName', CompanyName);
        JsonBC.WriteTo(MensajeBC);

        JsonAzure.add('Commando', 'REGISTRAR');
        JsonAzure.Add('ID', Identificador);
        JsonAzure.Add('CompanyName', CompanyName);
        JsonAzure.Add('OnPremise', Format(EsOnPremise()));
        JsonAzure.Add('SandBox', Format(EsSandBox()));

        JsonAzure.add('Mensaje_BC', MensajeBC);
        JsonAzure.add('Mensaje_App', Encriptado);
        JsonAzure.WriteTo(RequestBody);

        IAzureFunctionsAuthentication := AzureFunctionsAuthentication.CreateCodeAuth(CompanyInfo."URL API", CompanyInfo."Azure Code");
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(IAzureFunctionsAuthentication, RequestBody, 'application/json');
        if AzureFunctionsResponse.IsSuccessful() then begin
            AzureFunctionsResponse.GetResultAsText(RespuestaAzure);
            Verificar_Mensaje(CompanyInfo, RespuestaAzure);

            JsonEntrada.ReadFrom(RespuestaAzure);

            Respuesta := DatoJsonTexto(jsonEntrada, 'Mensaje_BC');
            IF Respuesta = '' then error('No Existe json BC en Registro');

            jsonBC.ReadFrom(Respuesta);
            Id_Dispositivo := DatoJsonTexto(jsonBC, 'Id_Dispositivo');

            IF Id_Dispositivo <> '' then begin
                Dispositivos.Reset;
                Dispositivos.SetRange(Code, Id_Dispositivo);
                IF NOT Dispositivos.Findfirst then begin
                    CLEAR(Dispositivos);
                    Dispositivos.Code := Id_Dispositivo;
                    Dispositivos.Insert;
                end;
                Dispositivos.Baja := False;
                Dispositivos."posting Date" := WorkDate();
                Dispositivos.Modify;
            end;

            Respuesta := DatoJsonTexto(jsonEntrada, 'Mensaje_App');

            IF (Respuesta = '') THEN BEGIN
                Respuesta := DatoJsonTexto(jsonEntrada, 'Mensaje_Error');
                ERROR(Respuesta);
            END;
        end
        else
            Error('Post request failed.\Details: %1', AzureFunctionsResponse.GetError());
    end;

    procedure Renovar(xJson: Text) Respuesta: Text
    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        IAzureFunctionsAuthentication: Interface "Azure Functions Authentication";
        jsonEntrada: JsonObject;
        JsonBC: JsonObject;
        JsonAzure: JsonObject;
        Encriptado: Text;
        MensajeBC: Text;
        RespuestaAzure: text;
        RequestBody: text;
        CompanyInfo: record "Company Information";
        Identificador: Guid;
    begin
        Get_CompanyInfo(CompanyInfo);
        Identificador := CreateGuid();

        Encriptado := xJson;

        JsonBC.Add('Licencia_BC', CompanyInfo."License BC");
        JsonBC.Add('Id_Polux', CompanyInfo."License Aura-SGA");
        JsonBC.Add('CompanyName', CompanyName);
        JsonBC.WriteTo(MensajeBC);

        JsonAzure.add('Commando', 'RENOVAR');
        JsonAzure.Add('ID', Identificador);
        JsonAzure.Add('CompanyName', CompanyName);
        JsonAzure.Add('OnPremise', Format(EsOnPremise()));
        JsonAzure.Add('SandBox', Format(EsSandBox()));

        JsonAzure.add('Mensaje_BC', MensajeBC);
        JsonAzure.add('Mensaje_App', Encriptado);
        JsonAzure.WriteTo(RequestBody);

        IAzureFunctionsAuthentication := AzureFunctionsAuthentication.CreateCodeAuth(CompanyInfo."URL API", CompanyInfo."Azure Code");
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(IAzureFunctionsAuthentication, RequestBody, 'application/json');
        if AzureFunctionsResponse.IsSuccessful() then begin
            AzureFunctionsResponse.GetResultAsText(RespuestaAzure);
            Verificar_Mensaje(CompanyInfo, RespuestaAzure);

            JsonEntrada.ReadFrom(RespuestaAzure);

            Respuesta := DatoJsonTexto(jsonEntrada, 'Mensaje_App');
        end
        else
            Error('Post request failed.\Details: %1', AzureFunctionsResponse.GetError());
    end;


    procedure Eliminar_Registro_APP(DispositivoID: Code[20])
    begin
        Eliminar_Registro(DispositivoID, 'UNREGISTER-APP');
    end;

    procedure Eliminar_Registro_BC(xDispositivo: code[20])
    begin
        Eliminar_Registro(xDispositivo, 'UNREGISTER-BC');
    end;

    local procedure Eliminar_Registro(DispositivoID: code[20]; Comando: code[20])
    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        IAzureFunctionsAuthentication: Interface "Azure Functions Authentication";
        Dispositivos: record Dispositivos;
        jsonToken: JsonToken;
        JsonAzure: JsonObject;
        jsonEntrada: JsonObject;
        jsonBC: JsonObject;
        RespuestaAzure: text;
        RequestBody: text;
        CompanyInfo: record "Company Information";
        Identificador: Guid;
        MensajeBC: text;
    begin
        Dispositivos.Reset;
        Dispositivos.SetRange(Code, DispositivoID);
        IF NOT Dispositivos.Findfirst then error('No Existe Dispositivo: ' + DispositivoID);

        Get_CompanyInfo(CompanyInfo);
        Identificador := CreateGuid();

        JsonBC.Add('Licencia_BC', CompanyInfo."License BC");
        JsonBC.Add('Id_Polux', CompanyInfo."License Aura-SGA");
        jsonBC.add('Id_Dispositivo', DispositivoID);
        JsonBC.Add('CompanyName', CompanyName);
        JsonBC.WriteTo(MensajeBC);

        JsonAzure.add('Commando', Comando);
        JsonAzure.Add('ID', Identificador);
        JsonAzure.Add('CompanyName', CompanyName);
        JsonAzure.add('Mensaje_BC', MensajeBC);
        JsonAzure.WriteTo(RequestBody);

        IAzureFunctionsAuthentication := AzureFunctionsAuthentication.CreateCodeAuth(CompanyInfo."URL API", CompanyInfo."Azure Code");
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(IAzureFunctionsAuthentication, RequestBody, 'application/json');
        if AzureFunctionsResponse.IsSuccessful() then begin
            AzureFunctionsResponse.GetResultAsText(RespuestaAzure);
            JsonEntrada.ReadFrom(RespuestaAzure);
            IF Json_Read_Label(jsonEntrada, 'Estado') <> 'OK' Then Error(Json_Read_Label(jsonEntrada, 'Mensaje_Error'));

            Verificar_Mensaje(CompanyInfo, RespuestaAzure);
            jsonBC.ReadFrom(DatoJsonTexto(jsonEntrada, 'Mensaje_BC'));
            IF Json_Read_Label(jsonBC, 'Estado') <> 'OK' Then Error(Json_Read_Label(jsonBC, 'Mensaje_Error'));

            Dispositivos.Baja := True;
            Dispositivos.Modify;
        end
        else
            Error('Post request failed.\Details: %1', AzureFunctionsResponse.GetError());
    end;

    procedure Informacion()
    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        IAzureFunctionsAuthentication: Interface "Azure Functions Authentication";
        CompanyInfo: record "Company Information";
        Dispositivos: record Dispositivos;
        JsonBC: JsonObject;
        JsonAzure: JsonObject;
        JsonRespuesta: JsonObject;
        JsonInfo: JsonObject;
        RequestBody: text;
        JsonInfoOut: JsonObject;
        MensajeBC: text;
        respuestaAzure: Text;
        respuesta: Text;
        jsonToken: JsonToken;
        jsonTokenLines: JsonToken;
        jsonDetalle: JsonObject;
        jsonResponse: JsonObject;
        jsonArrayLines: JsonArray;
        Identificador: Guid;
        Codigo: code[20];
    begin
        Get_CompanyInfo(CompanyInfo);

        Identificador := CreateGuid();

        JsonBC.Add('Licencia_BC', CompanyInfo."License BC");
        JsonBC.Add('Id_Polux', CompanyInfo."License Aura-SGA");
        JsonBC.Add('CompanyName', CompanyName);
        JsonBC.WriteTo(MensajeBC);

        JsonAzure.add('Commando', 'INFO');
        JsonAzure.Add('ID', Identificador);
        JsonAzure.Add('CompanyName', CompanyName);
        JsonAzure.add('Mensaje_BC', MensajeBC);
        JsonAzure.WriteTo(RequestBody);

        IAzureFunctionsAuthentication := AzureFunctionsAuthentication.CreateCodeAuth(CompanyInfo."URL API", CompanyInfo."Azure Code");
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(IAzureFunctionsAuthentication, RequestBody, 'application/json');
        if AzureFunctionsResponse.IsSuccessful() then begin
            AzureFunctionsResponse.GetResultAsText(RespuestaAzure);
            Verificar_Mensaje(CompanyInfo, RespuestaAzure);

            jSonRespuesta.ReadFrom(RespuestaAzure);
            jsonInfo.ReadFrom(DatoJsonTexto(jSonRespuesta, 'Mensaje_BC'));

            CompanyInfo."Licencias Activas" := DatoJsonInteger(JsonInfo, 'Licencias_Activas');
            CompanyInfo."Licencias Usadas" := DatoJsonInteger(JsonInfo, 'Licencias_Usadas');
            CompanyInfo."Fecha Vto Licencias" := string2date(DatoJsonTexto(JsonInfo, 'Fecha_Vto'));
            CompanyInfo.Modify;




            jsonInfo.get('Devices', jsonTokenLines);
            jsonArrayLines := jsonTokenLines.AsArray();

            foreach jsonTokenLines in jsonArrayLines do begin
                if jsonDetalle.ReadFrom(FORMAT(jsonTokenLines)) then begin
                    jsonDetalle.Get('Id_Dispositivo', jsonToken);
                    Codigo := jsonToken.AsValue().AsText();

                    IF (Codigo <> '') then begin
                        CLEAR(Dispositivos);
                        Dispositivos.Reset;
                        Dispositivos.SetRange(Code, Codigo);
                        IF NOT Dispositivos.Findfirst then begin
                            CLEAR(Dispositivos);
                            Dispositivos.Validate(code, Codigo);
                            Dispositivos.Insert(true);
                        end;

                        Dispositivos.validate(Code, Codigo);

                        Dispositivos.Validate(IP, Json_Read_Label(jsonDetalle, 'IP'));
                        Dispositivos.validate("posting Date", String2Date(Json_Read_Label(jsonDetalle, 'Fecha_Registro')));
                        Dispositivos.Validate(Baja, False);
                        Dispositivos.Validate(ID, Identificador);
                        Dispositivos.Modify(true);
                    end;
                end;
            end;

            Dispositivos.Reset;
            Dispositivos.SetRange(baja, false);
            Dispositivos.SetFilter(Id, '<>%1', Identificador);
            Dispositivos.deleteall(true);

            if (DatoJsonTexto(JsonInfo, 'Estado') = 'NOK') then
                Message(DatoJsonTexto(JsonInfo, 'Error'));


        end
        else
            Error('Post request failed.\Details: %1', AzureFunctionsResponse.GetError());

    end;

    #EndRegion

    #region Funciones_Auxiliares
    local procedure Verificar_Mensaje(CompanyInfo: record "Company Information"; Mensaje: Text)
    var
        jsonEntrada: JsonObject;
        jsonBC: JsonObject;
    begin
        JsonEntrada.ReadFrom(Mensaje);

        Mensaje := DatoJsonTexto(jsonEntrada, 'Mensaje_BC');
        JsonBC.ReadFrom(Mensaje);
        IF (text.UpperCase(DatoJsonTexto(JsonBC, 'Licencia_BC')) <> text.UpperCase(CompanyInfo."License BC")) or
           (text.UpperCase(DatoJsonTexto(JsonBC, 'Id_Polux')) <> text.UpperCase(CompanyInfo."License Aura-SGA")) then
            error('Destinatario del mensaje erróneo');
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

    #endregion

    #region Test
    procedure Test_Hola()
    var
        Respuesta: text;
    begin
        Message(Hola());
    end;

    procedure Test_Registro()
    var
        Mensaje: text;
    begin

        Mensaje := '{"Registro":"SEFdb1Vg2OnXJyaHFEgRtxHAWj34du/7oTLxrA7t9uhrVwPGSfT7Kt1qiGk9Od8TP3Sli+u7v77zaUbIUjyFzwv0M/FFEbq7NchK+L0mAkk="}';
        MESSAGE(Registro(Mensaje));
    end;

    #endregion

    #region Json

    local procedure Json_Read_Label(json: JsonObject; Etiqueta: text): Text
    var
        jsonToken: JsonToken;
        jVariable: Text;
    begin

        jVariable := '';
        if json.Get(Etiqueta, jsonToken) then begin
            if jsonToken.AsValue().IsNull then
                exit('')
            else begin
                jVariable := jsonToken.AsValue().AsText();
                exit(jVariable);
            end;
        end else begin
            exit('');
        end;

        //json.Get(Etiqueta, jsonToken);
        //Valor := jsonToken.AsValue().AsText();
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

    local procedure DatoArrayJsonTexto(xObjeto: JsonObject; xNodo: Text): JsonArray
    var
        VJsonTokenParte: JsonToken;
        vArray: JsonArray;
    begin

        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            vArray := VJsonTokenParte.AsArray();
            exit(vArray);
        end else begin
            exit(vArray);
        end;
    end;

    local procedure DatoJsonInteger(xObjeto: JsonObject; xNodo: Text): Integer
    var
        VJsonTokenParte: JsonToken;
        jVariable: Integer;
    begin
        jVariable := 0;
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit(0)
            else begin
                jVariable := VJsonTokenParte.AsValue().AsInteger();
                exit(jVariable);
            end;
        end else begin
            exit(0);
        end;
    end;

    local procedure String2Date(texto: text) Fecha: Date
    var
        dd: Integer;
        mm: Integer;
        yyyy: Integer;
        n: integer;
    begin

        IF (texto = '') THEN begin
            Fecha := DMY2DATE(31, 12, 2999)
        end else begin

            Fecha := 0D;

            n := StrPos(texto, '/');
            IF (n > 0) then begin
                Evaluate(dd, copystr(texto, 1, n - 1));
                texto := COPYSTR(texto, n + 1, STRLEN(texto) - n);
            end;
            n := StrPos(texto, '/');
            IF (n > 0) then begin
                Evaluate(mm, copystr(texto, 1, n - 1));
                texto := COPYSTR(texto, n + 1, STRLEN(texto) - n);
            end;
            Evaluate(yyyy, texto);

            if (dd <> 0) AND (mm <> 0) AND (yyyy <> 0) then fecha := DMY2DATE(dd, mm, yyyy);

        end;
    end;
    #Endregion


    var
        lblErrorJson: Label 'Incorrect format. A Json was expected', Comment = 'ESP=Formato incorrecto. Se esperaba un Json';

}
