codeunit 71742 "SGA License Management"
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


        jsonMOTD.add('ID_Dispositivo', DispositivoId);
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

        jsonArray.WriteTo(textojson);
        jsonMOTD.add('MOTD', textoJson);

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

    procedure Registro(xJson: Text) Respuesta: Text
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
        JsonBC.Add('ID_Polux', CompanyInfo."License Aura-SGA");
        JsonBC.WriteTo(MensajeBC);

        JsonAzure.add('Commando', 'REGISTRAR');
        JsonAzure.Add('ID', Identificador);
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


    procedure Eliminar_Registro_BC(DispositivoID: code[20])
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
        JsonBC.Add('ID_Polux', CompanyInfo."License Aura-SGA");
        jsonBC.add('ID_Dispositivo', DispositivoID);
        JsonBC.WriteTo(MensajeBC);

        JsonAzure.add('Commando', 'UNREGISTER-BC');
        JsonAzure.Add('ID', Identificador);
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
        JsonBC.Add('ID_Polux', CompanyInfo."License Aura-SGA");
        JsonBC.WriteTo(MensajeBC);

        JsonAzure.add('Commando', 'INFO');
        JsonAzure.Add('ID', Identificador);
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
           (text.UpperCase(DatoJsonTexto(JsonBC, 'ID_Polux')) <> text.UpperCase(CompanyInfo."License Aura-SGA")) then
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

    local procedure Json_Read_Label(json: JsonObject; Etiqueta: text) Valor: Text
    var
        jsonToken: JsonToken;

    begin
        json.Get(Etiqueta, jsonToken);
        Valor := jsonToken.AsValue().AsText();
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
    #Endregion

    #region DISPARADORES

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Source Doc. Inbound", 'OnAfterCreateWhseReceiptHeaderFromWhseRequest', '', false, false)]
    local procedure OnAfterCreateWhseReceiptHeaderFromWhseRequest(var WhseReceiptHeader: Record "Warehouse Receipt Header"; var WarehouseRequest: Record "Warehouse Request"; var GetSourceDocuments: Report "Get Source Documents");
    var
        WarehouseSetup: record "Warehouse Setup";
        WhseReceiptLine: Record "Warehouse receipt Line";
    begin
        WarehouseSetup.Reset;
        IF NOT WarehouseSetup.Findfirst then exit;
        IF NOT WarehouseSetup."Cantidad recepcion a cero" then exit;

        WhseReceiptLine.Reset;
        WhseReceiptLine.setrange("No.", WhseReceiptHeader."No.");
        WhseReceiptLine.modifyall("Qty. to Receive", 0);
        WhseReceiptLine.ModifyAll("Qty. to Receive (Base)", 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt (Yes/No)", 'OnAfterWhsePostReceiptRun', '', false, false)]
    local procedure OnAfterWhsePostReceiptRun(var WhseReceiptLine: Record "Warehouse Receipt Line"; WhsePostReceipt: Codeunit "Whse.-Post Receipt")
    var
        WarehouseSetup: record "Warehouse Setup";
        WhseReceiptLine2: Record "Warehouse Receipt Line";
        TrackLine: record "Tracking Specification";

    begin
        WhseReceiptLine2.reset;
        WhseReceiptLine2.SetRange("No.", WhseReceiptLine."No.");
        WhseReceiptLine2.SetRange("Line No.", WhseReceiptLine."Line No.");
        IF NOT WhseReceiptLine2.Findfirst then exit;

        WarehouseSetup.Reset;
        IF NOT WarehouseSetup.Findfirst then exit;
        IF NOT WarehouseSetup."Cantidad recepcion a cero" then exit;

        TrackLine.reset;
        trackLine.setrange("Source Type", WhseReceiptLine2."Source Type");
        trackLine.Setrange("Source Subtype", WhseReceiptLine2."Source Subtype");
        TrackLine.SetRange("Source ID", WhseReceiptLine2."Source No.");
        TrackLine.SetRange("Source Ref. No.", WhseReceiptLine2."Source Line No.");
        TrackLine.SetRange("Item No.", WhseReceiptLine2."Item No.");
        TrackLine.SetRange("Variant Code", WhseReceiptLine2."Variant Code");
        TrackLine.CalcSums("Qty. to Handle", "Qty. to Handle (Base)");

        WhseReceiptLine2."Qty. to Receive" := TrackLine."Qty. to Handle";
        WhseReceiptLine2."Qty. to Receive (Base)" := TrackLine."Qty. to Handle (Base)";
        WhseReceiptLine2.Modify;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Source Doc. Outbound", 'OnAfterCreateWhseShipmentHeaderFromWhseRequest', '', false, false)]
    local procedure OnAfterCreateWhseShipmentHeaderFromWhseRequest(var WarehouseRequest: Record "Warehouse Request"; var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WarehouseSetup: record "Warehouse Setup";
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WarehouseSetup.Reset;
        IF NOT WarehouseSetup.Findfirst then exit;
        IF NOT WarehouseSetup."Cantidad envio a cero" then exit;

        WhseShptLine.Reset;
        WhseShptLine.setrange("No.", WhseShptHeader."No.");
        WhseShptLine.modifyall("Qty. to Ship", 0);
        WhseShptLine.ModifyAll("Qty. to Ship (Base)", 0);
    end;


    // Crear info lote y serie obligatorio
    [EventSubscriber(ObjectType::Codeunit, codeunit::"Item Jnl.-Post Line", 'OnAfterInsertItemLedgEntry', '', False, False)]
    local procedure OnAfterInsertItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer; var ValueEntryNo: Integer; var ItemApplnEntryNo: Integer; GlobalValueEntry: Record "Value Entry"; TransferItem: Boolean; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L"; var OldItemLedgerEntry: Record "Item Ledger Entry")
    var
        LotInfo: record "Lot No. Information";
        SerialInfo: Record "Serial No. Information";
    begin
        IF (ItemLedgerEntry."Lot No." = '') AND (ItemLedgerEntry."Serial No." = '') then exit;

        IF (ItemLedgerEntry."Lot No." <> '') THEN begin
            LotInfo.Reset;
            LotInfo.SetRange("Item No.", ItemLedgerEntry."Item No.");
            LotInfo.SetRange("Variant Code", ItemLedgerEntry."Variant Code");
            LotInfo.SetRange("Lot No.", ItemLedgerEntry."Lot No.");
            IF not LotInfo.Findfirst then begin
                CLEAR(LotInfo);
                LotInfo.Validate("Item No.", ItemLedgerEntry."Item No.");
                LotInfo.Validate("Variant Code", ItemLedgerEntry."Variant Code");
                LotInfo.Validate("Lot No.", ItemLedgerEntry."Lot No.");
                LotInfo.Insert(False);
            end;
        end;

        IF (ItemLedgerEntry."Serial No." <> '') THEN begin
            SerialInfo.Reset;
            SerialInfo.SetRange("Item No.", ItemLedgerEntry."Item No.");
            SerialInfo.SetRange("Variant Code", ItemLedgerEntry."Variant Code");
            SerialInfo.SetRange("Serial No.", ItemLedgerEntry."Serial No.");
            IF not SerialInfo.Findfirst then begin
                CLEAR(SerialInfo);
                SerialInfo.Validate("Item No.", ItemLedgerEntry."Item No.");
                SerialInfo.Validate("Variant Code", ItemLedgerEntry."Variant Code");
                SerialInfo.Validate("Serial No.", ItemLedgerEntry."Serial No.");
                SerialInfo.Insert(False);
            end;
        end;
    end;
    #Endregion

    var
        lblErrorJson: Label 'Incorrect format. A Json was expected', Comment = 'ESP=Formato incorrecto. Se esperaba un Json';

}
