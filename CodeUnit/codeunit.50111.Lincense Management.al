

codeunit 50111 "SGA License Management"
{

    trigger OnRun()
    begin

    end;

    procedure Test()
    begin
        Message(Enviar_Mensaje('TEST', ''));
    end;

    procedure Test_Encriptado()
    begin
        Message(Enviar_Mensaje('TEST-CRYPT', 'RjkuP/hLI8vN6T9CpFptkA=='));
    end;

    procedure Test_Registro()
    begin
        MESSAGE(Registro('{Registro:"+0tH/qy6Ag8su817wu2HkUeCp7BgD6cWaJn+1aSjWJ95CaWufpIQc8UW08OCh2KtJWio4SIId4TnB0LEOfQ9EYTCLPjU+mo487X7qmKo6CRytlHXEG9Ldjf1O4i6xAyt"}'));
    end;

    procedure Vector_AES() Respuesta: text
    var
        CompanyInfo: Record "Company Information";
        VJsonObjectRecurso: JsonObject;
        VJsonText: Text;
    begin
        CompanyInfo.Reset;
        IF not CompanyInfo.findfirst then error('No Existe Información Empresa');
        IF CompanyInfo."URL API" = '' then error('No se ha definido URL para accesso -Información Empresa-');
        IF CompanyInfo."Azure Code" = '' then error('No se ha definido Azure Code -Información Empresa-');
        IF CompanyInfo."Vector AES" = '' then error('No se ha indicado Vector AES -Información Empresa-');

        Respuesta := CompanyInfo."Vector AES";

        VJsonObjectRecurso.Add('Vector', CompanyInfo."Vector AES");
        VJsonObjectRecurso.WriteTo(VJsonText);
        exit(VJsonText);
    end;


    procedure Registro(xJson: Text): Text
    var
        VJsonRegistroIn: JsonObject;
        VJsonRegistroOut: JsonObject;
        VJsonRegistroPoluxOut: JsonObject;
        VJsonRegistroPoluxIn: JsonObject;
        CompanyInfo: record "Company Information";
        Encriptado: text;
        json: text;
    begin
        If not VJsonRegistroIn.ReadFrom(xJson) then EXIT(lblErrorJson);

        CompanyInfo.Reset;
        IF NOT CompanyInfo.FindFirst() then error('No Existe confirngación empresa');

        Encriptado := DatoJsonTexto(VJsonRegistroIn, 'Registro');

        VJsonRegistroPoluxOut.Add('Licencia_BC', 'Licencia 12');
        VJsonRegistroPoluxOut.Add('ID_Polux', CompanyInfo."License Polux SGA");
        VJsonRegistroPoluxOut.Add('App', Encriptado);

        VJsonRegistroPoluxOut.WriteTo(json);
        MESSAGE(Enviar_Mensaje('REGISTRAR', json));
    end;




    local procedure Enviar_Mensaje(Comando: text; Value: text) Respuesta: text
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

        CompanyInfo.Reset;
        IF not CompanyInfo.findfirst then error('No Existe Información Empresa');
        IF CompanyInfo."URL API" = '' then error('No se ha definido URL para accesso -Información Empresa-');
        IF CompanyInfo."Azure Code" = '' then error('No se ha definido Azure Code -Información Empresa-');
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
        VJsonTokenParte: JsonToken;
        jVariable: Text;
    begin
        jVariable := '';
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit('')
            else begin
                jVariable := VJsonTokenParte.AsValue().AsText();
                exit(jVariable);
            end;
        end else begin
            exit('');
        end;
    end;


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

    var
        lblErrorJson: Label 'Incorrect format. A Json was expected', Comment = 'ESP=Formato incorrecto. Se esperaba un Json';
}