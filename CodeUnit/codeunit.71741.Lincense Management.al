codeunit 71741 "SGA License Management"
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
        JsonRegistroPoluxOut.Add('App', Encriptado);

        JsonRegistroPoluxOut.WriteTo(json);

        if NOT Enviar_Mensaje('REGISTRAR', json, Respuesta) then Error('Error Envío mensaje: ' + GetLastErrorText());

        If not JsonAzure.ReadFrom(Respuesta) then EXIT(lblErrorJson);
        IF CompanyInfo."License BC" <> DatoJsonTexto(JsonAzure, 'Licencia_BC') then error('Mensaje Recibido con destinatario incorrecto');
        IF CompanyInfo."License Aura-SGA" <> DatoJsonTexto(JsonAzure, 'ID_Polux') then error('Mensaje Recibido con ID Aura incorrecto');

        Respuesta := DatoJsonTexto(JsonAzure, 'Mensaje_App');
    end;



    procedure Informacion(var Licencias: record Licencias)
    var
        CompanyInfo: record "Company Information";
        JsonInfoOut: JsonObject;
        json: text;
        respuesta: Text;
        jsonToken: JsonToken;
        jsonTokenLines: JsonToken;
        jsonInfo: JsonObject;
        jsonDetalle: JsonObject;
        jsonResponse: JsonObject;
        jsonArrayLines: JsonArray;
        n: integer;

    begin
        Get_CompanyInfo(CompanyInfo);

        Licencias.Reset;
        Licencias.deleteall;

        JsonInfoOut.Add('Licencia_BC', CompanyInfo."License BC");
        JsonInfoOut.Add('ID_Polux', CompanyInfo."License Aura-SGA");
        JsonInfoOut.WriteTo(json);

        // KKK Respuesta := Enviar_Mensaje('INFORMACION', json);

        if jsonInfo.ReadFrom(respuesta) then begin
            Licencias.Id := 0;

            jsonInfo.Get('Estado', jsonToken);
            Licencias.Estado := jsonToken.AsValue().AsText();
            jsonInfo.Get('Error', jsonToken);
            Licencias.Error := jsonToken.AsValue().AsText();
            jsonInfo.Get('Licencias_Activas', jsonToken);
            Licencias."Licencias Activas" := jsonToken.AsValue().AsInteger();
            jsonInfo.Get('Licencias_Usadas', jsonToken);
            Licencias."Licencias Usadas" := jsonToken.AsValue().AsInteger();
            Licencias.Insert;

            jsonInfo.get('Devices', jsonTokenLines);
            jsonArrayLines := jsonTokenLines.AsArray();

            n := 0;
            foreach jsonTokenLines in jsonArrayLines do begin
                if jsonDetalle.ReadFrom(FORMAT(jsonTokenLines)) then begin
                    n += 1;
                    Licencias.Id := n;
                    jsonDetalle.Get('Id_Dispositivo', jsonToken);
                    Licencias.Device := jsonToken.AsValue().AsText();
                    jsonDetalle.Get('IP', jsonToken);
                    Licencias.IP := jsonToken.AsValue().AsText();
                    jsonDetalle.Get('Fecha_Registro', jsonToken);
                    //Licencias."Posting Date" := jsonToken.AsValue().AsText();
                    Licencias.Insert;
                end;
            end;
        end;

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
        Stream: InStream;
        Url: Text;
        t: text;
        sw9: Boolean;
        Identificador: guid;

    begin
        Respuesta := 'Error de Conexión';
        sw9 := True;

        Get_CompanyInfo(CompanyInfo);
        Identificador := CreateGuid();

        url := CompanyInfo."URL API" + '?Code=' + CompanyInfo."Azure Code" + '&Command=' + Comando + '&ID=' + format(Identificador);
        if Value <> '' then url += '&Value=' + Value;

        sw9 := client.Post(Url, Content, ResponseMessage);
        IF sw9 then sw9 := ResponseMessage.IsSuccessStatusCode();

        if sw9 then begin
            ResponseMessage.Content().ReadAs(Stream);
            Respuesta := '';

            while not (Stream.EOS) do begin
                Stream.ReadText(t, 100);
                Respuesta += t;
            end;
            Respuesta := Respuesta;
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