codeunit 71740 WsApplicationStandard //Cambios 2024.02.16
{
    #region LOGIN

    procedure Login(xJson: Text): Text
    var
        RecRecursos: Record Resource;
        RecWarehouseSetup: Record "Warehouse Setup";
        RecLocation: Record Location;
        c: JsonToken;
        input: JsonObject;
        VJsonObjectLogin: JsonObject;
        VJsonTokenPIN: JsonToken;
        lPIN: Text;
        lLocation: Text;
        VJsonObjectRecurso: JsonObject;
        VJsonArrayRecurso: JsonArray;
        VJsonObjectOTS: JsonObject;
        VJsonArrayOTS: JsonArray;
        VJsonArrayParte: JsonArray;
        VJsonText: Text;
    begin

        If not VJsonObjectLogin.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lPIN := DatoJsonTexto(VJsonObjectLogin, 'PIN');
        lLocation := DatoJsonTexto(VJsonObjectLogin, 'Location');

        Clear(RecRecursos);
        RecRecursos.SetRange(RecRecursos.Pin, lPIN);

        IF NOT RecRecursos.FindFirst() THEN
            exit(lblErrorRecurso);

        if lLocation = '' then begin
            if NOT App_Location(lLocation) then
                exit(GetLastErrorText());
        end;

        Clear(RecLocation);
        RecLocation.SetRange(RecLocation.Code, lLocation);
        if NOT RecLocation.FindFirst() then exit(lblErrorAlmacen);


        VJsonObjectRecurso.Add('No', RecRecursos."No.");
        VJsonObjectRecurso.Add('Name', RecRecursos.Name);
        VJsonObjectRecurso.Add('Copiar', FormatoBoolean(RecRecursos."Permite Copiar"));
        VJsonObjectRecurso.Add('Regularizar', FormatoBoolean(RecRecursos."Permite Regularizar"));
        VJsonObjectRecurso.Add('Inventario', FormatoBoolean(RecRecursos."Ver cantidad inventario"));

        RecWarehouseSetup.Get();
        VJsonObjectRecurso.Add('UsarPaquete', FormatoBoolean(RecWarehouseSetup."Usar paquetes"));
        VJsonObjectRecurso.Add('VerRecepcion', FormatoBoolean(RecWarehouseSetup."Ver Recepcion"));
        VJsonObjectRecurso.Add('VerSalidas', FormatoBoolean(RecWarehouseSetup."Ver Salidas"));
        VJsonObjectRecurso.Add('VerInventario', FormatoBoolean(RecWarehouseSetup."Ver Inventario"));
        VJsonObjectRecurso.Add('VerMovimientos', FormatoBoolean(RecWarehouseSetup."Ver Movimientos"));


        RecLocation.CalcFields(RecLocation."Tiene Ubicaciones");
        VJsonObjectRecurso.Add('AlmacenAvanzado', FormatoBoolean(RecLocation."Almacen Avanzado"));
        VJsonObjectRecurso.Add('TieneUbicaciones', FormatoBoolean(RecLocation."Tiene Ubicaciones"));



        VJsonObjectRecurso.Add('LoteInternoObligatorio', FormatoBoolean(RecWarehouseSetup."Lote Interno Obligatorio"));
        VJsonObjectRecurso.Add('UsarLoteProveedor', FormatoBoolean(RecWarehouseSetup."Usar Lote Proveedor"));
        VJsonObjectRecurso.Add('LoteAutomatico', FormatoBoolean(RecWarehouseSetup."Lote Automatico"));



        VJsonObjectRecurso.Add('Location', RecLocation.Code);
        VJsonObjectRecurso.Add('NombreAlamcen', RecLocation.Name);

        VJsonObjectRecurso.Add('RequiereAlmacenamiento', FormatoBoolean(RecLocation."Require Put-away"));
        VJsonObjectRecurso.Add('RequierePicking', FormatoBoolean(RecLocation."Require Pick"));

        VJsonObjectRecurso.Add('ContRecepciones', FormatoNumero(Contador_Recepciones(lLocation)));
        VJsonObjectRecurso.Add('ContAlmacenamiento', FormatoNumero(Contador_Trabajos(lLocation, 1)));
        VJsonObjectRecurso.Add('ContPicking', FormatoNumero(Contador_Trabajos(lLocation, 2)));
        VJsonObjectRecurso.Add('ContInventario', FormatoNumero(Contador_Inventario(lLocation)));
        VJsonObjectRecurso.Add('ContTrabajos', FormatoNumero(Contador_Trabajos(lLocation, 0)));

        VJsonObjectRecurso.Add('ContEnvios', FormatoNumero(Contador_Envios(lLocation)));

        VJsonObjectRecurso.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    #endregion

    #region CONTADORES

    local procedure Contador_Recepciones(xLocation: Text): Integer
    var
        RecWhsReceiptLine: Record "Warehouse Receipt Line";
        RecWhsReceiptHeader: Record "Warehouse Receipt Header";
    begin
        Clear(RecWhsReceiptLine);
        RecWhsReceiptLine.SetFilter("Qty. Outstanding", '>%1', 0);
        RecWhsReceiptLine.SetRange("Location Code", xLocation);
        exit(RecWhsReceiptLine.Count());
    end;


    local procedure Contador_Envios(xLocation: Text): Integer
    var
        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        RecWhsShipmentHeader: Record "Warehouse Shipment Header";
    begin
        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetFilter("Qty. Outstanding", '>%1', 0);
        RecWhsShipmentLine.SetRange("Location Code", xLocation);
        exit(RecWhsShipmentLine.Count());
    end;


    /// <summary>
    /// Contador_Trabajos.
    /// </summary>
    /// <param name="xLocation">Alamcen</param>
    /// <param name="xTipo">0:Almacenamiento 1:Picking</param>
    /// <returns>Return value of type Integer.</returns>
    local procedure Contador_Trabajos(xLocation: Text; xTipo: Integer): Integer
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        Contador: Integer;
    begin
        Contador := 0;
        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."Location Code", xLocation);
        case xTipo of
            1:
                RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::"Put-away");
            2:
                RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::Pick);
        end;
        if RecWarehouseActivityHeader.findset then
            repeat
                Clear(RecWarehouseActivityLine);
                clear(RecWarehouseActivityLine);
                RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
                RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
                RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Qty. Outstanding", '>0');
                Contador += RecWarehouseActivityLine.Count();
            until RecWarehouseActivityHeader.Next() = 0;

        exit(Contador);
    end;

    local procedure Contador_Inventario(xLocation: Text): Integer
    var
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecLocation: Record Location;
        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecPhyInvetRecordHeader: Record "Phys. Invt. Record Header";
    begin
        //RecWarehouseSetup.Get();

        RecLocation.Get(xLocation);

        if (xLocation = '') then exit(0);

        if (RecLocation."Almacen Avanzado") then begin
            Clear(RecWarehouseJournalLine);
            RecWarehouseJournalLine.SetRange("Location Code", xLocation);
            RecWarehouseJournalLine.SetRange("Journal Template Name", RecLocation.AppInvJournalTemplateName);
            RecWarehouseJournalLine.SetRange("Journal Batch Name", RecLocation.AppInvJournalBatchName);
            exit(RecWarehouseJournalLine.Count());
        end else begin
            Clear(RecPhyInvetRecordHeader);
            RecPhyInvetRecordHeader.SetRange(RecPhyInvetRecordHeader.App, true);
            RecPhyInvetRecordHeader.SetRange("Location Code", xLocation);
            exit(RecPhyInvetRecordHeader.Count());

        end;


    end;




    #endregion

    #region WEB SERVICES

    procedure WsAlmacenes(): Text
    var
        RecLocation: Record Location;
        VJsonObjectLocation: JsonObject;
        VJsonArrayLocation: JsonArray;

        VJsonText: Text;
    begin

        Clear(RecLocation);
        if RecLocation.FindSet() then begin
            repeat

                VJsonObjectLocation.Add('Location', RecLocation.Code);
                VJsonObjectLocation.Add('Name', RecLocation.Name);

                VJsonArrayLocation.Add(VJsonObjectLocation.Clone());
                clear(VJsonObjectLocation);
            until RecLocation.Next() = 0;

        end;

        VJsonArrayLocation.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    procedure WsRecepciones(xJson: Text): Text
    var
        RecWhsReceiptHeader: Record "Warehouse Receipt Header";
        VJsonObjectDato: JsonObject;
        VJsonObjectReceipts: JsonObject;
        VJsonArrayReceipts: JsonArray;
        lLocation: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN exit(lblErrorAlmacen);

        Clear(RecWhsReceiptHeader);
        RecWhsReceiptHeader.SetFilter("Document Status", '<>%1', RecWhsReceiptHeader."Document Status"::"Completely Received");
        RecWhsReceiptHeader.SetFilter("Location Code", lLocation);
        if RecWhsReceiptHeader.FindSet() then begin
            repeat

                VJsonObjectReceipts := Objeto_Recepcion(RecWhsReceiptHeader."No.");
                VJsonArrayReceipts.Add(VJsonObjectReceipts.Clone());
                clear(VJsonObjectReceipts);
            until RecWhsReceiptHeader.Next() = 0;

        end;

        VJsonArrayReceipts.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    procedure WsRecepcionarContenedor(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        jRecepcion: Text;
        VJsonText: Text;


    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Recepcionar_Objeto(VJsonObjectContenedor);


        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);
        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);

    end;

    procedure WsEliminarContenedor(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jRecepcion: Text;

    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Eliminar_Contenedor_Recepcion(xJson);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsEliminarCantidadRecepcion(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jRecepcion: Text;

    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');

        Eliminar_Cantidad_Recepcion(xJson);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsRegistrarRecepcion(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jRecepcion: Text;
        jLinea: Integer;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLinea := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');

        Registrar_Recepcion(jRecepcion, jLinea);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Recepcion(jRecepcion).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsContenidoUbicacion(xJson: Text): Text
    var
        RecLocations: Record Location;
        VJsonObjectContenedor: JsonObject;

        jArrayContenidoAux: JsonArray;
        jArrayContenido: JsonArray;
        jToken: JsonToken;
        i: Integer;

        VJsonText: Text;
        jTrackNo: Text;
        jZone: Text;
        jBin: Text;
        jLocation: Text;

        iTipoDato: Code[1];
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
        jTrackNoAux: Text;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jTrackNo := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jBin := DatoJsonTexto(VJsonObjectContenedor, 'Bin');
        jZone := DatoJsonTexto(VJsonObjectContenedor, 'Zone');
        jLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        Clear(RecLocations);
        RecLocations.Get(jLocation);


        if (jTrackNo <> '') then
            iTipoDato := Tipo_Dato(jTrackNo)
        else
            iTipoDato := '';

        RecLocations.CalcFields("Tiene Ubicaciones");
        if RecLocations."Tiene Ubicaciones" then begin

            case iTipoDato of
                'I':
                    begin
                        jArrayContenidoAux := Contenidos_Ubicacion(jTrackNo, jZone, jBin, jLocation, iTipoDato, jTrackNo);
                        for i := 0 to jArrayContenidoAux.Count - 1 do begin
                            jArrayContenidoAux.Get(i, jToken);
                            jArrayContenido.Add(jToken);
                        end;

                    end;
                'L':
                    begin
                        jTrackNoAux := '';
                        Clear(RecLotNo);
                        RecLotNo.SetCurrentKey("Item No.");
                        RecLotNo.SetRange("Lot No.", jTrackNo);
                        if RecLotNo.FindSet() then begin
                            if (RecLotNo."Item No." <> jTrackNoAux) then begin
                                jTrackNoAux := RecLotNo."Item No.";
                                jArrayContenidoAux := Contenidos_Ubicacion(RecLotNo."Item No.", jZone, jBin, jLocation, iTipoDato, jTrackNo);
                                for i := 0 to jArrayContenidoAux.Count - 1 do begin
                                    jArrayContenidoAux.Get(i, jToken);
                                    jArrayContenido.Add(jToken);
                                end;
                            end;
                        end;

                    end;
                'S':
                    begin
                        jTrackNoAux := '';
                        Clear(RecSerialNo);
                        RecSerialNo.SetCurrentKey("Item No.");
                        RecSerialNo.SetRange("Serial No.", jTrackNo);
                        if RecSerialNo.FindSet() then begin
                            if (RecSerialNo."Item No." <> jTrackNoAux) then begin
                                jTrackNoAux := RecSerialNo."Item No.";
                                jArrayContenidoAux := Contenidos_Ubicacion(RecSerialNo."Item No.", jZone, jBin, jLocation, iTipoDato, jTrackNo);
                                for i := 0 to jArrayContenidoAux.Count - 1 do begin
                                    jArrayContenidoAux.Get(i, jToken);
                                    jArrayContenido.Add(jToken);
                                end;
                            end;
                        end;

                    end;
                'P':
                    begin
                        jTrackNoAux := '';
                        Clear(RecPackage);
                        RecPackage.SetCurrentKey("Item No.");
                        RecPackage.SetRange("Package No.", jTrackNo);
                        if RecPackage.FindSet() then begin
                            if (RecPackage."Item No." <> jTrackNoAux) then begin
                                jTrackNoAux := RecPackage."Item No.";
                                jArrayContenidoAux := Contenidos_Ubicacion(RecPackage."Item No.", jZone, jBin, jLocation, iTipoDato, jTrackNo);
                                for i := 0 to jArrayContenidoAux.Count - 1 do begin
                                    jArrayContenidoAux.Get(i, jToken);
                                    jArrayContenido.Add(jToken);
                                end;
                            end;
                        end;

                    end;
                else begin

                    jArrayContenido := Contenidos_Ubicacion('', jZone, jBin, jLocation, iTipoDato, jTrackNo);

                end;

            end;

            jArrayContenido.WriteTo(VJsonText);
            exit(VJsonText);

            //EXIT(Contenidos_Ubicacion(jItemNo, jZone, jBin, jLocation));
        end else begin
            EXIT(Contenidos_Sin_Ubicacion(jTrackNo, jLocation, iTipoDato, jTrackNo));
        end;

    end;

    procedure WsPicking(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        VJsonArrayPicking: JsonArray;
        lLocation: Text;

        lNo: Text;
    begin

        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectContenedor, 'No');
        lLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        VJsonText := Lineas_Picking(lNo, lLocation);

        exit(VJsonText);

    end;

    procedure WsAlmacenamiento(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        VJsonArrayPicking: JsonArray;
        lLocation: Text;
        lNo: Text;
    begin

        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectContenedor, 'No');
        lLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        VJsonText := Lineas_Almacenamiento(lNo, lLocation);

        exit(VJsonText);

    end;

    procedure WsRegistrarAlmacenamiento(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;
        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jItemNo: Text;
        jLotNo: Text;
        jNo: Text;
        jBinTo: Text;
        jSerialNo: Text;
        jQuantity: Decimal;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        jSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'QtyToHandle');

        jBinTo := DatoJsonTexto(VJsonObjectDatos, 'BinTo');

        jNo := DatoJsonTexto(VJsonObjectDatos, 'No');

        exit(Registrar_Almacenamiento(jNo, jLotNo, jItemNo, jBinTo, jSerialNo, jQuantity));

    end;

    procedure WsInventarioTrazabilidad(xJson: Text): Text
    var

        RecLocation: Record Location;

        VJsonObjectDatos: JsonObject;

        VJsonText: Text;

        lTrackNo: Text;
        lLocation: Text;
        lItemNo: Text;

    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lTrackNo := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        lItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        lLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');

        exit(Inventario_Trazabilidad(lLocation, lTrackNo, lItemNo));


    end;

    procedure WsEnvios(xJson: Text): Text
    var
        RecWhsShipmentHeader: Record "Warehouse Shipment Header";
        VJsonObjectDato: JsonObject;
        VJsonObjectShipments: JsonObject;
        VJsonArrayShipments: JsonArray;
        lLocation: Text;
        VJsonText: Text;
    begin

        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN exit(lblErrorAlmacen);

        Clear(RecWhsShipmentHeader);
        RecWhsShipmentHeader.SetFilter("Document Status", '<>%1', RecWhsShipmentHeader."Document Status"::"Completely Shipped");
        RecWhsShipmentHeader.SetRange("Location Code", lLocation);
        if RecWhsShipmentHeader.FindSet() then begin
            repeat

                VJsonObjectShipments := Objeto_Envio(RecWhsShipmentHeader."No.");
                VJsonArrayShipments.Add(VJsonObjectShipments.Clone());
                clear(VJsonObjectShipments);
            until RecWhsShipmentHeader.Next() = 0;

        end;

        VJsonArrayShipments.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    procedure WsEnviarContenedor(xJson: Text): Text
    var
        VJsonObjectDato: JsonObject;
        VJsonObjectShipment: JsonObject;

        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        lCantidad: Integer;
        lLineNo: Integer;
        lSourceLineNo: Integer;
        lItemNo: Text;
        lLocation: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        lSourceNo: Text;
        lNo: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectDato, 'No');
        lLineNo := DatoJsonInteger(VJsonObjectDato, 'LineNo');
        lCantidad := DatoJsonInteger(VJsonObjectDato, 'Quantity');
        lItemNo := DatoJsonTexto(VJsonObjectDato, 'Reference');
        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');
        lLotNo := DatoJsonTexto(VJsonObjectDato, 'LotNo');
        lSerialNo := DatoJsonTexto(VJsonObjectDato, 'SerialNo');
        lPackageNo := DatoJsonTexto(VJsonObjectDato, 'PackageNo');
        lSourceNo := DatoJsonTexto(VJsonObjectDato, 'SourceNo');
        lSourceLineNo := DatoJsonInteger(VJsonObjectDato, 'SourceLineNo');

        Asignar(lCantidad, lItemNo, lLocation, lLotNo, lSerialNo, lPackageNo, lSourceNo, lSourceLineNo);

        //Modificar cantidad a enviar

        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetRange("No.", lNo);
        RecWhsShipmentLine.SetRange("Line No.", lLineNo);
        IF NOT RecWhsShipmentLine.FindFirst() THEN exit(lblErrorEnvio);

        RecWhsShipmentLine.Validate("Qty. to Ship", RecWhsShipmentLine."Qty. to Ship" + lCantidad);
        RecWhsShipmentLine.Modify();

        VJsonObjectShipment := Objeto_Envio(lNo);

        VJsonObjectShipment.WriteTo(VJsonText);
        exit(VJsonText);
    end;

    procedure WsEnviarEliminarContenedor(xJson: Text): Text
    var
        VJsonObjectDato: JsonObject;
        VJsonObjectShipment: JsonObject;

        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        lCantidad: Integer;
        lLineNo: Integer;
        lEntryNo: Integer;
        lItemNo: Text;
        lLocation: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        lSourceNo: Text;
        lNo: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectDato, 'No');
        lLineNo := DatoJsonInteger(VJsonObjectDato, 'LineNo');
        lCantidad := DatoJsonInteger(VJsonObjectDato, 'Quantity');
        lEntryNo := DatoJsonInteger(VJsonObjectDato, 'EntryNo');

        Eliminar_De_Envio(lCantidad, lEntryNo);

        //Modificar cantidad a enviar

        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetRange("No.", lNo);
        RecWhsShipmentLine.SetRange("Line No.", lLineNo);
        IF NOT RecWhsShipmentLine.FindFirst() THEN exit(lblErrorEnvio);

        RecWhsShipmentLine.Validate("Qty. to Ship", RecWhsShipmentLine."Qty. to Ship" - lCantidad);
        RecWhsShipmentLine.Modify();

        VJsonObjectShipment := Objeto_Envio(lNo);

        VJsonObjectShipment.WriteTo(VJsonText);
        exit(VJsonText);
    end;

    procedure WsEnviarEliminarLineaEnvio(xJson: Text): Text
    var
        VJsonObjectDato: JsonObject;
        VJsonObjectShipment: JsonObject;

        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        lCantidad: Integer;
        lLineNo: Integer;
        lEntryNo: Integer;
        lItemNo: Text;
        lLocation: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        lSourceNo: Text;
        lNo: Text;
        VJsonText: Text;
    begin
        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectDato, 'No');
        lLineNo := DatoJsonInteger(VJsonObjectDato, 'LineNo');
        lCantidad := DatoJsonInteger(VJsonObjectDato, 'Quantity');

        //Modificar cantidad a enviar

        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetRange("No.", lNo);
        RecWhsShipmentLine.SetRange("Line No.", lLineNo);
        IF NOT RecWhsShipmentLine.FindFirst() THEN exit(lblErrorEnvio);

        RecWhsShipmentLine.Validate("Qty. to Ship", RecWhsShipmentLine."Qty. to Ship" - lCantidad);
        RecWhsShipmentLine.Modify();

        VJsonObjectShipment := Objeto_Envio(lNo);

        VJsonObjectShipment.WriteTo(VJsonText);
        exit(VJsonText);
    end;

    procedure WsRegistrarEnvio(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        jEnvio: Text;
        jLinea: Integer;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jEnvio := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLinea := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');

        Registrar_Envio(jEnvio, jLinea);

        //Actualizar_Cantidad_Recibir(jRecepcion);
        Objeto_Envio(jEnvio).WriteTo(VJsonText);

        //Se devolverá un Json con las líneas de reserva
        EXIT(VJsonText);


    end;

    procedure WsInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jItemNo: Text;
        jBin: Text;
        jZone: Text;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');
        jZone := DatoJsonTexto(VJsonObjectDatos, 'Zone');

        exit(Inventario_Recurso(jRecurso, jLocation, jZone, jBin, jItemNo));

    end;

    procedure WsAgregarLineaInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        RecLocation: Record Location;

        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jReferencia: Text;
        jItemNo: Text;
        jZone: Text;
        jBin: Text;
        jTrackNo: Text;
        jQuantity: Decimal;

        jItemNoFilter: Text;
        jZoneFilter: Text;
        jBinFilter: Text;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jReferencia := DatoJsonTexto(VJsonObjectDatos, 'Referencia');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');

        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jTrackNo := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');

        jItemNoFilter := DatoJsonTexto(VJsonObjectDatos, 'ItemNoFilter');
        jZoneFilter := DatoJsonTexto(VJsonObjectDatos, 'ZoneFilter');
        jBinFilter := DatoJsonTexto(VJsonObjectDatos, 'BinFilter');
        Validar_Linea_Inventario_Almacen_Avanzado(jTrackNo, jBin, jQuantity, jItemNo, jLocation);

        /*Clear(RecLocation);
        RecLocation.Get(jLocation);
        if RecLocation."Almacen Avanzado" then
            Validar_Linea_Inventario_Almacen_Avanzado(jTrackNo, jBinInv, jQuantity, jItemNo, jLocation)
        ELSE
            Validar_Linea_Inventario_Almacen_Basico(jTrackNo, jBinInv, jQuantity, jItemNo, jLocation);*/

        exit(Inventario_Recurso(jRecurso, jLocation, jZoneFilter, jBinFilter, jItemNoFilter));

    end;

    procedure WsMover(xJson: Text): Text
    var

        RecLocation: Record Location;
        RecWarehouseSetup: Record "Warehouse Setup";
        QueryContPaquete: Query "Lot Numbers by Bin";

        VJsonObjectDatos: JsonObject;

        lContenedor: Text;
        lAlmacen: Text;

        lUbicadionDesde: Text;
        lUbicacionHasta: Text;
        lCantidad: Decimal;
        lResource: Text;
        lItemNo: Text;
        lLotNo: Text;
        lSerialNo: Text;
        lPackageNo: Text;
        newPackageNo: Text;
        ltipo: Text;
        lTrackNo: Text;
    begin

        If not VJsonObjectDatos.ReadFrom(xJson) then
            exit('Respuesta no valida. Se esperaba un Json');

        lContenedor := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        lTipo := DatoJsonTexto(VJsonObjectDatos, 'Tipo');

        lItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        lUbicadionDesde := DatoJsonTexto(VJsonObjectDatos, 'BinFrom');
        lUbicacionHasta := DatoJsonTexto(VJsonObjectDatos, 'BinTo');
        lCantidad := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');
        lResource := DatoJsonTexto(VJsonObjectDatos, 'Resource');
        lAlmacen := DatoJsonTexto(VJsonObjectDatos, 'Location');
        lLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        lSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');
        lPackageNo := DatoJsonTexto(VJsonObjectDatos, 'PackageNo');


        if (ltipo = 'P') THEN begin

            Clear(QueryContPaquete);
            QueryContPaquete.SetFilter(QueryContPaquete.Location_Code, lAlmacen);
            QueryContPaquete.SetFilter(QueryContPaquete.Package_No, lContenedor);
            QueryContPaquete.SetFilter(QueryContPaquete.Sum_Qty_Base, '>%1', 0);
            QueryContPaquete.Open();
            while QueryContPaquete.READ do begin

                lTrackNo := '';
                if (QueryContPaquete.Lot_No <> '') then lTrackNo := QueryContPaquete.Lot_No;
                if (QueryContPaquete.Serial_No <> '') then lTrackNo := QueryContPaquete.Serial_No;

                AppCreateReclassWarehouse_Avanzado(lAlmacen, lUbicadionDesde, lUbicacionHasta, QueryContPaquete.Sum_Qty_Base, lTrackNo, lResource, QueryContPaquete.Item_No, QueryContPaquete.Lot_No, QueryContPaquete.Serial_No, lContenedor, lContenedor);

            end;


        END ELSE BEGIN

            RecWarehouseSetup.Get();
            IF (lPackageNo <> '') then begin
                IF (RecWarehouseSetup."Codigo Sin Paquete" = '') THEN ERROR(lblErrorPaqueteGenerico);

                if (lPackageNo <> RecWarehouseSetup."Codigo Sin Paquete") then
                    newPackageNo := RecWarehouseSetup."Codigo Sin Paquete"
                else
                    newPackageNo := lPackageNo;
            END;
            //Comprobar si se está metiendo en un paquete
            IF Existe_Paquete(lUbicacionHasta) then begin
                newPackageNo := lUbicacionHasta;
                lUbicacionHasta := Ubicacion_Paquete(newPackageNo, lAlmacen);
            end;

            Clear(RecLocation);
            RecLocation.Get(lAlmacen);
            if RecLocation."Almacen Avanzado" then
                AppCreateReclassWarehouse_Avanzado(lAlmacen, lUbicadionDesde, lUbicacionHasta, lCantidad, lContenedor, lResource, lItemNo, lLotNo, lSerialNo, lPackageNo, newPackageNo);

        END;
        exit('OK');

    end;

    procedure WsMovimientosAlmacen(xJson: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        VJsonArrayPicking: JsonArray;
        lLocation: Text;
        lNo: Text;
    begin

        If not VJsonObjectContenedor.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lNo := DatoJsonTexto(VJsonObjectContenedor, 'No');
        lLocation := DatoJsonTexto(VJsonObjectContenedor, 'Location');

        VJsonText := Movimientos_Almacen(lNo, lLocation);

        exit(VJsonText);

    end;

    procedure WsRegistrarMovimiento(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;
        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jItemNo: Text;
        jLotNo: Text;
        jNo: Text;
        jBinTo: Text;
        jBinFrom: Text;
        jSerialNo: Text;
        jQuantity: Decimal;
        jDocumentType: Text;
        jDocumentNo: Text;
        jDocumentLineNo: Integer;
        jLineNoTake: Integer;
        jLineNoPlace: Integer;
        rDocumentType: Enum "Warehouse Activity Document Type";
    begin

        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');
        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        jSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');

        jDocumentType := DatoJsonTexto(VJsonObjectDatos, 'DocumentType');
        jDocumentNo := DatoJsonTexto(VJsonObjectDatos, 'DocumentNo');
        jDocumentLineNo := DatoJsonInteger(VJsonObjectDatos, 'DocumentLineNo');

        jBinTo := DatoJsonTexto(VJsonObjectDatos, 'BinTo');
        jBinFrom := DatoJsonTexto(VJsonObjectDatos, 'BinFrom');

        jNo := DatoJsonTexto(VJsonObjectDatos, 'No');
        jLineNoTake := DatoJsonInteger(VJsonObjectDatos, 'LineNoTake');
        jLineNoPlace := DatoJsonInteger(VJsonObjectDatos, 'LineNoPlace');

        case jDocumentType of
            'Receipt':
                rDocumentType := rDocumentType::Receipt;
            'Shipment':
                rDocumentType := rDocumentType::Shipment;
            'Movement Worksheet':
                rDocumentType := rDocumentType::"Movement Worksheet";
        end;

        Registrar_Movimiento(jNo, jLineNoTake, jLineNoPlace, rDocumentType, jDocumentNo, jDocumentLineNo, jBinFrom, jBinTo, jQuantity, jItemNo, jLotNo, jSerialNo);

        exit(Movimientos_Almacen('', jLocation));

    end;

    procedure WsRegistrosInventario(xJson: Text): Text
    var
        RecRegistroInventario: Record "Phys. Invt. Record Header";
        VJsonObjectDato: JsonObject;
        VJsonObjectInventory: JsonObject;
        VJsonArrayInventory: JsonArray;
        lLocation: Text;
        VJsonText: Text;
    begin

        If not VJsonObjectDato.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        lLocation := DatoJsonTexto(VJsonObjectDato, 'Location');

        if (lLocation = '') THEN exit(lblErrorAlmacen);

        Clear(RecRegistroInventario);
        RecRegistroInventario.SetRange("Location Code", lLocation);
        RecRegistroInventario.SetRange(App, true);
        if RecRegistroInventario.FindSet() then begin
            repeat

                VJsonObjectInventory := Objeto_Registro_Inventario(RecRegistroInventario."Order No.", RecRegistroInventario."Recording No.");
                VJsonArrayInventory.Add(VJsonObjectInventory.Clone());
                clear(VJsonObjectInventory);
            until RecRegistroInventario.Next() = 0;

        end;

        VJsonArrayInventory.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    procedure WsLineasRegistroInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        vJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jOrderNo: Text;
        jRecordingNo: Integer;
    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');

        if (jRecurso = '') then exit(lblErrorRecurso);

        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');
        jOrderNo := DatoJsonTexto(VJsonObjectDatos, 'OrderNo');
        jRecordingNo := DatoJsonInteger(VJsonObjectDatos, 'RecordingNo');

        EXIT(Lineas_Registro_Inventario_Recurso(jRecurso, jLocation, jOrderNo, jRecordingNo));
    end;

    procedure WsAgregarLineaRegistroInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        RecLocation: Record Location;
        RecBin: Record Bin;
        vJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jReferencia: Text;
        jItemNo: Text;
        jZone: Text;
        jBin: Text;
        jTrackNo: Text;
        jTrackType: Text;

        jQuantity: Decimal;

        jOrderNo: Text;
        jRecordingNo: Integer;
        jLineNo: Integer;

    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');

        if (jRecurso = '') then exit(lblErrorRecurso);

        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');

        jOrderNo := DatoJsonTexto(VJsonObjectDatos, 'OrderNo');
        jRecordingNo := DatoJsonInteger(VJsonObjectDatos, 'RecordingNo');

        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jTrackNo := DatoJsonTexto(VJsonObjectDatos, 'TrackNo');
        jTrackType := DatoJsonTexto(VJsonObjectDatos, 'TrackType');
        jBin := DatoJsonTexto(VJsonObjectDatos, 'Bin');
        jQuantity := DatoJsonDecimal(VJsonObjectDatos, 'Quantity');

        Clear(RecBin);
        RecBin.SetRange(RecBin.Code, jBin);
        if Not RecBin.FindFirst() then EXIT(StrSubstNo(lblErrorUbicacion, jBin));

        Agregar_Linea_Registro_Inventario(jTrackType, jTrackNo, jBin, jQuantity, jItemNo, jLocation, jOrderNo, jRecordingNo);

        EXIT(Lineas_Registro_Inventario_Recurso(jRecurso, jLocation, jOrderNo, jRecordingNo));


    end;

    procedure WsEliminarLineaRegistroInventario(xJson: Text): Text
    var


        VJsonObjectDatos: JsonObject;

        RecLocation: Record Location;
        RecPhyInvetRecordLine: Record "Phys. Invt. Record Line";

        vJsonText: Text;
        jRecurso: Text;
        jLocation: Text;
        jReferencia: Text;
        jItemNo: Text;
        jZone: Text;
        jBin: Text;
        jTrackNo: Text;
        jTrackType: Text;

        jQuantity: Decimal;

        jOrderNo: Text;
        jRecordingNo: Integer;
        jLineNo: Integer;

    begin


        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jRecurso := DatoJsonTexto(VJsonObjectDatos, 'ResourceNo');

        if (jRecurso = '') then exit(lblErrorRecurso);

        jLocation := DatoJsonTexto(VJsonObjectDatos, 'Location');

        jOrderNo := DatoJsonTexto(VJsonObjectDatos, 'OrderNo');
        jRecordingNo := DatoJsonInteger(VJsonObjectDatos, 'RecordingNo');
        jLineNo := DatoJsonInteger(VJsonObjectDatos, 'LineNo');

        Clear(RecPhyInvetRecordLine);
        RecPhyInvetRecordLine.SetRange("Order No.", jOrderNo);
        RecPhyInvetRecordLine.SetRange("Recording No.", jRecordingNo);
        RecPhyInvetRecordLine.SetRange("Line No.", jLineNo);
        if RecPhyInvetRecordLine.FindFirst() then begin

            if (RecPhyInvetRecordLine."Recorded Without Order") then
                RecPhyInvetRecordLine.delete()
            else begin
                RecPhyInvetRecordLine.Validate(Quantity, 0);
                RecPhyInvetRecordLine.Validate(RecPhyInvetRecordLine.Recorded, false);
                RecPhyInvetRecordLine.Modify();
            end;
        end;


        EXIT(Lineas_Registro_Inventario_Recurso(jRecurso, jLocation, jOrderNo, jRecordingNo));

    end;


    procedure WsCrearPaquete(): Text
    var
        VJsonObjectPaquete: JsonObject;

        numPaquete: Text;
        vJsonText: Text;
    begin

        numPaquete := Crear_Paquete();

        VJsonObjectPaquete.Add('PackageNo', numPaquete);

        VJsonObjectPaquete.WriteTo(vJsonText);
        exit(vJsonText);
    end;


    #endregion


    #region PAQUETE

    local procedure Crear_Paquete(): Text
    var
        RecWarehouseSetup: Record "Warehouse Setup";
        RecPackages: Record "Package No. Information";
        cuNoSeriesManagement: Codeunit NoSeriesManagement;
        numPaquete: Text;
    begin
        Clear(RecWarehouseSetup);
        RecWarehouseSetup.Get();

        if (RecWarehouseSetup."Numero Serie Paquete" = '') then error(lblErrorSinSeriePaquete);
        numPaquete := cuNoSeriesManagement.GetNextNo(RecWarehouseSetup."Numero Serie Paquete", WorkDate, true);

        Clear(RecPackages);
        RecPackages.Init();
        RecPackages."Package No." := numPaquete;
        RecPackages.Insert();

        exit(RecPackages."Package No.");

    end;

    #endregion


    #region NUEVA SISTEMATICA


    procedure WsInformacionContenedor(xJson: Text): Text
    var
        VJsonObjectDatos: JsonObject;
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
        RecItem: Record Item;
        jBusqueda: Text;
        jItemNo: Text;
        jLotNo: Text;
        jSerialNo: Text;

        vItemNo: Text;
        vDescription: Text;
        vTrackNo: Text;
        vTipoTrack: Text; //I: Item - S:Serie - L:Lote
    begin

        If not VJsonObjectDatos.ReadFrom(xJson) then
            ERROR(lblErrorJson);

        jBusqueda := DatoJsonTexto(VJsonObjectDatos, 'Busqueda');
        jItemNo := DatoJsonTexto(VJsonObjectDatos, 'ItemNo');
        jLotNo := DatoJsonTexto(VJsonObjectDatos, 'LotNo');
        jSerialNo := DatoJsonTexto(VJsonObjectDatos, 'SerialNo');

        vItemNo := '';
        vDescription := '';
        vTrackNo := '';
        vTipoTrack := '';

        //Comprobar si es un serie
        Clear(RecSerialNo);
        if (jSerialNo <> '') then
            RecSerialNo.SetRange("Serial No.", jSerialNo)
        else
            RecSerialNo.SetRange("Serial No.", jBusqueda);
        if RecSerialNo.FindFirst() then begin
            vItemNo := RecSerialNo."Item No.";
            vDescription := RecSerialNo.Description;
            vTrackNo := RecSerialNo."Serial No.";
            vTipoTrack := 'S';
            Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
        end;

        //Comprobar si es un lote
        Clear(RecLotNo);
        if (jLotNo <> '') then
            RecLotNo.SetRange("Lot No.", jSerialNo)
        else
            RecLotNo.SetRange("Lot No.", jBusqueda);
        if (jItemNo <> '') then
            RecLotNo.SetRange("Item No.", jItemNo);
        if RecLotNo.FindFirst() then begin
            vTrackNo := RecLotNo."Lot No.";
            vTipoTrack := 'L';
            IF (RecLotNo.Count() > 1) THEN begin
                vItemNo := '';
                vDescription := '';
            end ELSE begin
                vItemNo := RecLotNo."Item No.";
                vDescription := RecLotNo.Description;
            end;
            Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
        end;

        Clear(RecPackage);
        RecPackage.SetRange("Package No.", jBusqueda);
        if RecPackage.FindFirst() then begin
            vItemNo := RecPackage."Item No.";
            vDescription := RecPackage.Description;
            vTrackNo := RecPackage."Package No.";
            vTipoTrack := 'P';
            Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
        end;

        if (jItemNo <> '') then
            jBusqueda := jItemNo;

        vDescription := Sacar_Item(jBusqueda);
        IF (jBusqueda <> '') then begin
            vItemNo := jBusqueda;
            vDescription := vDescription;
            vTrackNo := '';
            vTipoTrack := 'I';
            Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
        end;

        vItemNo := '';
        vDescription := '';
        vTrackNo := '';
        vTipoTrack := '';
        Exit(JsonContenedor(vItemNo, vDescription, vTipoTrack, vTrackNo));
    end;

    local procedure JsonContenedor(xItemNo: Text; xDescription: Text; xTipoTrack: Text; xTrackNo: Text): Text
    var
        VJsonObjectContenedor: JsonObject;
        VJsonText: Text;
        vTipoSeguimiento: Text;
    begin

        // 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento
        vTipoSeguimiento := '99';
        if xItemNo <> '' then
            vTipoSeguimiento := FORMAT(TipoSeguimientoProducto(xItemNo));

        VJsonObjectContenedor.Add('ItemNo', xItemNo);
        VJsonObjectContenedor.Add('Description', xDescription);
        VJsonObjectContenedor.Add('TrackType', xTipoTrack);
        VJsonObjectContenedor.Add('TrackNo', xTrackNo);
        VJsonObjectContenedor.Add('TrackingType', vTipoSeguimiento);

        VJsonObjectContenedor.WriteTo(VJsonText);

        exit(VJsonText);
    end;


    local procedure Sacar_Item(var xDato: Text): Text;
    var
        RecItem: Record Item;
        vItem: Text;
    begin

        Clear(RecItem);
        RecItem.SetRange("No.", xDato);
        if RecItem.FindFirst() then exit(RecItem.Description);

        vItem := Buscar_Referencia_Cruzada(xDato, '');
        IF (vItem <> '') then begin
            RecItem.Get(vItem);
            xDato := RecItem."No.";
            exit(RecItem.Description);
        end else begin
            xDato := '';
            exit('');
        end;




    end;


    #endregion

    #region MOVIMIENTOS ALMACEN

    procedure Movimientos_Almacen(xNo: Code[20]; xLocation: Text): Text
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

        RecWarehouseSetup: Record "Warehouse Setup";

        VJsonObjectPicking: JsonObject;
        VJsonArrayPicking: JsonArray;
        VJsonObjectLineas: JsonObject;
        VJsonArrayLineas: JsonArray;

        VJsonText: Text;
        lUbicacionEnvio: Text;
        lLineNoPlace: Integer;

    begin

        RecWarehouseSetup.get();

        Clear(RecWarehouseActivityHeader);
        if xNo <> '' then
            RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."No.", xNo);

        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."Location Code", xLocation);
        //RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::Pick);
        if RecWarehouseActivityHeader.findset then begin

            VJsonObjectPicking.Add('No', RecWarehouseActivityHeader."No.");
            VJsonObjectPicking.Add('SystemDate', FormatoFecha(RecWarehouseActivityHeader.SystemCreatedAt));
            VJsonObjectPicking.Add('Type', Format(RecWarehouseActivityHeader.Type));

            //VACIAR CANTIDAD A MANIPULAR
            clear(RecWarehouseActivityLine);
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."No.", RecWarehouseActivityHeader."No.");
            //RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Document", RecWarehouseActivityLine."Source Document"::"Sales Order");
            RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Lot No.", '=%1', '');
            IF RecWarehouseActivityLine.FindSet() THEN
                repeat
                    RecWarehouseActivityLine.Validate("Qty. to Handle", 0);
                //RecWarehouseActivityLine.Modify();
                UNTIL RecWarehouseActivityLine.Next() = 0;

            repeat
                lLineNoPlace := 0;
                clear(RecWarehouseActivityLine);
                RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
                RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Take);
                RecWarehouseActivityLine.SetFilter("Qty. Outstanding", '>%1', RecWarehouseActivityLine."Qty. to Handle");
                if RecWarehouseActivityLine.FindSet() then begin
                    repeat

                        clear(RecWarehouseActivityLineAux);
                        RecWarehouseActivityLineAux.SetRange("No.", RecWarehouseActivityHeader."No.");
                        RecWarehouseActivityLineAux.SetRange("Item No.", RecWarehouseActivityLine."Item No.");
                        RecWarehouseActivityLineAux.SetRange("Source Line No.", RecWarehouseActivityLine."Source Line No.");
                        RecWarehouseActivityLineAux.SetRange("Source Subline No.", RecWarehouseActivityLine."Source Subline No.");
                        RecWarehouseActivityLineAux.SetFilter("Line No.", '>%1', RecWarehouseActivityLine."Line No.");
                        RecWarehouseActivityLineAux.SetRange("Action Type", RecWarehouseActivityLineAux."Action Type"::Place);
                        if RecWarehouseActivityLineAux.FindFirst() then begin
                            lUbicacionEnvio := RecWarehouseActivityLineAux."Bin Code";
                            lLineNoPlace := RecWarehouseActivityLineAux."Line No.";
                        end;


                        VJsonObjectLineas.Add('No', Format(RecWarehouseActivityLine."No."));
                        VJsonObjectLineas.Add('LineNoTake', FormatoNumero(RecWarehouseActivityLine."Line No."));
                        VJsonObjectLineas.Add('LineNoPlace', FormatoNumero(lLineNoPlace));

                        VJsonObjectLineas.Add('Type', Format(RecWarehouseActivityLine."Activity Type"));
                        VJsonObjectLineas.Add('ItemNo', RecWarehouseActivityLine."Item No.");
                        VJsonObjectLineas.Add('Description', Descripcion_ItemNo(RecWarehouseActivityLine."Item No."));

                        VJsonObjectLineas.Add('DocumentType', FORMAT(RecWarehouseActivityLine."Whse. Document Type"));
                        VJsonObjectLineas.Add('DocumentNo', RecWarehouseActivityLine."Whse. Document No.");
                        VJsonObjectLineas.Add('DocumentLineNo', RecWarehouseActivityLine."Whse. Document Line No.");

                        VJsonObjectLineas.Add('BinFrom', RecWarehouseActivityLine."Bin Code");
                        VJsonObjectLineas.Add('BinTo', lUbicacionEnvio);
                        VJsonObjectLineas.Add('LotNo', RecWarehouseActivityLine."Lot No.");
                        VJsonObjectLineas.Add('SerialNo', RecWarehouseActivityLine."Serial No.");
                        VJsonObjectLineas.Add('PackageNo', RecWarehouseActivityLine."Package No.");

                        /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
                        case TipoSeguimientoProducto(RecWarehouseActivityLine."Item No.") of
                            0:
                                begin
                                    VJsonObjectLineas.Add('TrackNo', '');
                                    VJsonObjectLineas.Add('TipoTrack', 'I');
                                end;
                            2, 3, 5, 6:
                                begin
                                    VJsonObjectLineas.Add('TrackNo', RecWarehouseActivityLine."Serial No.");
                                    VJsonObjectLineas.Add('TipoTrack', 'S');
                                end;
                            1, 4:
                                begin
                                    VJsonObjectLineas.Add('TrackNo', RecWarehouseActivityLine."Lot No.");
                                    VJsonObjectLineas.Add('TipoTrack', 'L');
                                end;

                        end;

                        VJsonObjectLineas.Add('Quantity', QuitarPunto(Format(RecWarehouseActivityLine.Quantity)));
                        VJsonObjectLineas.Add('QtyToHandle', QuitarPunto(Format(RecWarehouseActivityLine."Qty. to Handle")));
                        VJsonObjectLineas.Add('QtyOutstanding', QuitarPunto(Format(RecWarehouseActivityLine."Qty. Outstanding")));
                        VJsonArrayLineas.Add(VJsonObjectLineas.Clone());

                        clear(VJsonObjectLineas);
                    until RecWarehouseActivityLine.Next() = 0;

                end;

                VJsonObjectPicking.Add('Lines', VJsonArrayLineas.Clone());
                Clear(VJsonArrayLineas);

                VJsonArrayPicking.Add(VJsonObjectPicking.Clone());
                clear(VJsonObjectPicking);

            until RecWarehouseActivityHeader.Next() = 0

        end;

        VJsonArrayPicking.WriteTo(VJsonText);

        exit(VJsonText);

    end;





    procedure Crear_Movimientos_Almacenamiento()
    var

    begin



    end;



    #endregion

    #region RECEPCIONES

    local procedure Objeto_Recepcion(xNo: code[20]): JsonObject
    var
        RecWhsReceiptLine: Record "Warehouse Receipt Line";
        RecPurchaseHeader: Record "Purchase Header";
        RecSalesHeader: Record "Sales Header";
        RecItemReference: Record "Item Reference";
        RecWhsReceiptHeader: Record "Warehouse Receipt Header";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecPurchaseLine: Record "Purchase Line";
        RecComentarios: Record "Warehouse Comment Line";
        RecItem: Record Item;
        RecItemTrackingCode: Record "Item Tracking Code";
        Comentarios: Text;

        //RecItem: Record Item;
        VJsonObjectReceipts: JsonObject;
        VJsonArrayReceipts: JsonArray;
        VJsonObjectLines: JsonObject;
        VJsonArrayLines: JsonArray;
        VJsonArrayReservas: JsonArray;

        VJsonText: Text;

        CR: Char;

    begin

        RecWarehouseSetup.Get();

        CR := 13;

        clear(RecWhsReceiptHeader);
        RecWhsReceiptHeader.SetRange("No.", xNo);
        if RecWhsReceiptHeader.FindFirst() then;

        //Actualizar_Cantidad_Recibir(RecWhsReceiptHeader."No.");

        Clear(VJsonObjectReceipts);

        VJsonObjectReceipts.Add('No', RecWhsReceiptHeader."No.");
        VJsonObjectReceipts.Add('Date', FormatoFecha(RecWhsReceiptHeader."Posting Date"));
        VJsonObjectReceipts.Add('VendorShipmentNo', RecWhsReceiptHeader."Vendor Shipment No.");
        VJsonObjectReceipts.Add('VendorName', '');
        VJsonObjectReceipts.Add('Return', 'False');
        VJsonObjectReceipts.Add('EsSubcontratacion', 'False');

        /*VJsonObjectReceipts.Add('EstadoRecepcion', Format(RecWhsReceiptHeader."Estado Recepcion"));
        if (RecWhsReceiptHeader."Estado Recepcion" = RecWhsReceiptHeader."Estado Recepcion"::"Recepcion urgente") then
            VJsonObjectReceipts.Add('Urgente', 'true')
        else
            VJsonObjectReceipts.Add('Urgente', 'False');*/

        //Comentarios

        Comentarios := '';
        Clear(RecComentarios);
        RecComentarios.SetRange("Table Name", RecComentarios."Table Name"::"Whse. Receipt");
        RecComentarios.SetRange("No.", RecWhsReceiptHeader."No.");
        //RecComentarios.SetRange(RecComentarios."Tipo Comentario", RecComentarios."Tipo Comentario"::APP);
        if RecComentarios.FindSet(false) then begin
            VJsonObjectReceipts.Add('TieneComentarios', 'true');
            repeat
                Comentarios += RecComentarios.Comment + '-*-';
            until RecComentarios.Next() = 0;
        END ELSE
            VJsonObjectReceipts.Add('TieneComentarios', 'false');

        VJsonObjectReceipts.Add('Comentarios', Comentarios);

        Clear(RecWhsReceiptLine);
        RecWhsReceiptLine.SetRange("No.", RecWhsReceiptHeader."No.");
        if RecWhsReceiptLine.FindSet() then begin

            //Buscar el nombre del proveedor                    
            if RecWhsReceiptLine."Source Document" = RecWhsReceiptLine."Source Document"::"Purchase Order" then begin
                Clear(RecPurchaseHeader);
                RecPurchaseHeader.SetRange("Document Type", RecPurchaseHeader."Document Type"::Order);
                RecPurchaseHeader.SetRange("No.", RecWhsReceiptLine."Source No.");
                if RecPurchaseHeader.FindFirst() then
                    VJsonObjectReceipts.Replace('VendorName', RecPurchaseHeader."Buy-from Vendor Name");

            end;

            if RecWhsReceiptLine."Source Document" = RecWhsReceiptLine."Source Document"::"Sales Return Order" then begin
                Clear(RecSalesHeader);
                RecSalesHeader.SetRange("Document Type", RecSalesHeader."Document Type"::"Return Order");
                RecSalesHeader.SetRange("No.", RecWhsReceiptLine."Source No.");
                if RecSalesHeader.FindFirst() then
                    VJsonObjectReceipts.Replace('VendorName', RecSalesHeader."Sell-to Customer Name");
                VJsonObjectReceipts.Replace('Return', 'True');
            end;

            repeat
                VJsonObjectLines.Add('LineNo', RecWhsReceiptLine."Line No.");
                VJsonObjectLines.Add('ProdOrderNo', '');
                VJsonObjectLines.Add('Reference', RecWhsReceiptLine."Item No.");
                VJsonObjectLines.Add('Description', RecWhsReceiptLine.Description);
                VJsonObjectLines.Add('TipoSeguimimento', Format(TipoSeguimientoProducto(RecWhsReceiptLine."Item No.")));
                VJsonObjectLines.Add('LoteInternoObligatorio', FormatoBoolean(RecWarehouseSetup."Lote Interno Obligatorio"));

                Clear(RecItem);
                RecItem.Get(RecWhsReceiptLine."Item No.");
                if (RecItem."Item Tracking Code" <> '') then begin
                    clear(RecItemTrackingCode);
                    RecItemTrackingCode.Get(RecItem."Item Tracking Code");
                    VJsonObjectLines.Add('Caducidad', FormatoBoolean(RecItemTrackingCode."Man. Expir. Date Entry Reqd."));
                end else
                    VJsonObjectLines.Add('Caducidad', FormatoBoolean(false));


                VJsonObjectLines.Add('ItemReference', Buscar_Referencia_Cruzada(RecWhsReceiptLine."Item No.", ''));
                VJsonObjectLines.Add('Outstanding', RecWhsReceiptLine."Qty. Outstanding (Base)");// ."Qty. Outstanding");
                VJsonObjectLines.Add('ToReceive', RecWhsReceiptLine."Qty. to Receive (Base)");// ."Qty. to Receive");

                if (RecWhsReceiptLine."Qty. to Receive (Base)" < RecWhsReceiptLine."Qty. Outstanding (Base)") then begin
                    VJsonObjectLines.Add('Complete', false);
                    if (RecWhsReceiptLine."Qty. to Receive (Base)" > 0) then
                        VJsonObjectLines.Add('Partial', true)
                    else
                        VJsonObjectLines.Add('Partial', false);

                end else begin
                    VJsonObjectLines.Add('Complete', true);
                    VJsonObjectLines.Add('Partial', false);
                end;
                //Se busca si tiene lote predefinido
                /*clear(RecPurchaseLine);
                RecPurchaseLine.SetRange("Document No.", RecWhsReceiptLine."Source No.");
                RecPurchaseLine.SetRange("Line No.", RecWhsReceiptLine."Source Line No.");
                if RecPurchaseLine.FindFirst() then
                    VJsonObjectLines.Add('Preasignado', RecPurchaseLine."Lote preasignado")
                else
                    VJsonObjectLines.Add('Preasignado', 'BAD' + RecWhsReceiptLine."Source No." + '--' + RecPurchaseLine."Lote preasignado");
                */

                Clear(VJsonArrayReservas);
                VJsonArrayReservas := Reservas(RecWhsReceiptLine);
                VJsonObjectLines.Add('Reservations', VJsonArrayReservas);

                VJsonArrayLines.Add(VJsonObjectLines.Clone());
                clear(VJsonObjectLines);

            until RecWhsReceiptLine.Next() = 0;

            VJsonObjectReceipts.Add('Lines', VJsonArrayLines);

            Clear(VJsonArrayLines);
            Clear(VJsonObjectLines);

        end;


        exit(VJsonObjectReceipts);

    end;

    local procedure Reservas(RecWhseReceiptLine: Record "Warehouse Receipt Line"): JsonArray
    var
        RecReservationEntry: Record "Reservation Entry";
        VJsonObjectReservas: JsonObject;
        VJsonArrayReservas: JsonArray;
    begin
        Clear(RecReservationEntry);
        RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
        RecReservationEntry.SETRANGE("Source ID", RecWhseReceiptLine."Source No.");
        RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseReceiptLine."Source Line No.");
        RecReservationEntry.SETRANGE("Item No.", RecWhseReceiptLine."Item No.");
        IF RecReservationEntry.FINDSET THEN BEGIN
            REPEAT
                VJsonObjectReservas.Add('LineNo', RecWhseReceiptLine."Line No.");
                VJsonObjectReservas.Add('EntryNo', RecReservationEntry."Entry No.");
                VJsonObjectReservas.Add('LotNo', RecReservationEntry."Lot No.");
                VJsonObjectReservas.Add('SerialNo', RecReservationEntry."Serial No.");
                VJsonObjectReservas.Add('Quantity', FormatoNumero(RecReservationEntry."Quantity (Base)"));

                VJsonArrayReservas.Add(VJsonObjectReservas.Clone());
                Clear(VJsonObjectReservas);

            UNTIL RecReservationEntry.NEXT = 0;
        END;

        exit(VJsonArrayReservas);
    end;

    /*local procedure Actualizar_Cantidad_Recibir(xRecepcion: Text)
    var
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecReservationEntry: Record "Reservation Entry";
        CantidadReservada: Decimal;
    begin

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SETRANGE("No.", xRecepcion);
        IF RecWhseReceiptLine.FINDSET THEN begin
            RecWhseReceiptLine.Validate("Qty. to Receive", 0);
            RecWhseReceiptLine.MODIFY();
            REPEAT
                CantidadReservada := 0;
                Clear(RecReservationEntry);
                RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
                RecReservationEntry.SETRANGE("Source ID", RecWhseReceiptLine."Source No.");
                RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseReceiptLine."Source Line No.");
                RecReservationEntry.SETRANGE("Item No.", RecWhseReceiptLine."Item No.");
                IF RecReservationEntry.FINDSET THEN
                    REPEAT
                        CantidadReservada := CantidadReservada + RecReservationEntry.Quantity;
                    UNTIL RecReservationEntry.NEXT = 0;

                RecWhseReceiptLine.Validate("Qty. to Receive", CantidadReservada / RecWhseReceiptLine."Qty. per Unit of Measure");// ("Qty. to Receive", CantidadReservada);

                RecWhseReceiptLine.MODIFY();
            UNTIL RecWhseReceiptLine.NEXT = 0;
        end;
    end;*/

    local procedure Recepcionar_Objeto(VJsonObjectContenedor: JsonObject)
    var
        RecWarehouseSetup: Record "Warehouse Setup";
        RecItem: Record Item;

        jReferencia: Text;
        jRecepcion: Text;
        jUnidades: Integer;
        jTotalContenedores: Integer;
        jLoteProveedor: Text;
        jLotePreasignado: Text;
        jSerie: Text;
        jRecurso: Text;
        BaseNumeroContenedor: Text;
        NumeracionInicial: Integer;
        i: Integer;
        NumContedor: Text;
        TextoContenedorFinal: Text;

        jImprimir: Boolean;

        iTipoSeguimiento: Integer;
    begin
        jReferencia := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jUnidades := DatoJsonInteger(VJsonObjectContenedor, 'Units');
        jTotalContenedores := DatoJsonInteger(VJsonObjectContenedor, 'Quantity');
        jLoteProveedor := DatoJsonTexto(VJsonObjectContenedor, 'VendorLotNo');
        jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');
        jRecurso := DatoJsonTexto(VJsonObjectContenedor, 'ResourceNo');

        if (jRecurso = '') then Error(lblErrorRecurso);

        //Comprobaciones
        //Referencia
        Existe_Referencia(jReferencia, false);

        RecWarehouseSetup.Get();

        BaseNumeroContenedor := '';
        iTipoSeguimiento := TipoSeguimientoProducto(jReferencia);
        case iTipoSeguimiento of
            1, 3, 4, 6://Lote
                begin
                    //Base para la creación del Nº Contenedor      
                    if (RecWarehouseSetup."Usar Lote Proveedor") then
                        BaseNumeroContenedor := jLoteProveedor
                    else
                        if (RecWarehouseSetup."Lote Automatico") then
                            BaseNumeroContenedor := Base_Numero_Contenedor(1, jReferencia);
                end;
        end;

        //Si es un contenedor unitario se añade 00 si son varios 01,02....
        if jTotalContenedores = 1 then
            NumeracionInicial := 0
        else
            NumeracionInicial := 1;

        for i := 1 to jTotalContenedores do begin

            if (BaseNumeroContenedor <> '') then begin
                NumContedor := Format(NumeracionInicial);
                if (StrLen(NumContedor) = 1) then
                    NumContedor := '00' + NumContedor;
                if (StrLen(NumContedor) = 2) then
                    NumContedor := '0' + NumContedor;

                TextoContenedorFinal := BaseNumeroContenedor + NumContedor;
            end else
                TextoContenedorFinal := '';


            //Si lleva un lote preasignado utilizamos ese
            if jLotePreasignado <> '' then begin
                TextoContenedorFinal := jLotePreasignado;
                jImprimir := false;
            end;

            Recepcionar_Contenedor(VJsonObjectContenedor, TextoContenedorFinal, NOT jImprimir, iTipoSeguimiento);

            NumeracionInicial += 1;

        end;
    end;

    local procedure Recepcionar_Contenedor(VJsonObjectContenedor: JsonObject; xContenedor: Text; xOmitirImpresion: Boolean; xTipoSeguimiento: Integer)
    var
        RecItem: Record Item;
        RecLote: Record "Lot No. Information";
        RecSerie: Record "Serial No. Information";
        RecWhseReceiptHeader: Record "Warehouse Receipt Header";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecWhseSetup: Record "Warehouse Setup";
        RecResource: Record Resource;
        RecPurchaseHeader: Record "Purchase Header";
        RecPurchaseLine: Record "Purchase Line";

        vNumReserva: Integer;

        jAlbaran: Text;
        jReferencia: Text;
        jRecepcion: Text;
        jUnidades: Integer;
        jLote: Text;
        jSerie: Text;
        jLoteProveedor: Text;
        jLotePreasignado: Text;
        jImprimir: Boolean;
        jEnAlerta: Boolean;
        jText: Text;
        jFoto: Text;
        jRecurso: Text;
        jMultiSerie: Boolean;
        jFechaCaducidad: Text;
        jPaquete: Text;
        FechaCaducidad: Date;

        vArraySeries: JsonArray;
        vJsonObjectSerie: JsonObject;
        vTokenSerie: JsonToken;

        vEncontrado: Boolean;
        vDiferencia: Integer;
        vDiferenciaActual: Integer;
        vLinea: Integer;

        cuBase64: Codeunit "Base64 Convert";
        cuTempBlob: Codeunit "Temp Blob";
        iStream: InStream;
        oStream: OutStream;
        NombreFoto: Text;

    begin

        RecWhseSetup.GeT();

        //Lectura de datos del Json
        jAlbaran := DatoJsonTexto(VJsonObjectContenedor, 'ShipmentNo');
        jReferencia := DatoJsonTexto(VJsonObjectContenedor, 'ItemNo');
        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jUnidades := DatoJsonInteger(VJsonObjectContenedor, 'Units');
        jLoteProveedor := DatoJsonTexto(VJsonObjectContenedor, 'VendorLotNo');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');

        jEnAlerta := DatoJsonBoolean(VJsonObjectContenedor, 'OnAlert');
        jRecurso := DatoJsonTexto(VJsonObjectContenedor, 'ResourceNo');
        jImprimir := DatoJsonBoolean(VJsonObjectContenedor, 'Print');

        jFechaCaducidad := DatoJsonTexto(VJsonObjectContenedor, 'ExpirationText');

        jPaquete := DatoJsonTexto(VJsonObjectContenedor, 'PackageNo');


        if (jFechaCaducidad <> '') then begin
            Evaluate(FechaCaducidad, jFechaCaducidad);
        end;



        //Comprobaciones
        //Referencia
        //Existe_Referencia(jReferencia, true);


        //Buscar la línea de recepción
        vEncontrado := false;
        vDiferencia := 99999;
        vLinea := 0;

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.RESET();
        RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
        RecWhseReceiptLine.SETRANGE("Item No.", jReferencia);
        RecWhseReceiptLine.SETFILTER(RecWhseReceiptLine."Qty. Outstanding", '>=%1', jUnidades);
        IF NOT RecWhseReceiptLine.FindSet() THEN Error(lblErrorLineasCantidad);
        repeat

            //Se busca las lineas que aun tengan cantidad pendiente mayor que la cantidad a recepcionar
            //Entre todas las líneas de la misma referencia se busca la que mejor se ajuste
            IF ((RecWhseReceiptLine."Qty. Outstanding" - RecWhseReceiptLine."Qty. to Receive") >= jUnidades) THEN begin
                vEncontrado := true;

                vDiferenciaActual := (RecWhseReceiptLine."Qty. Outstanding" - RecWhseReceiptLine."Qty. to Receive") - jUnidades;

                if (vDiferenciaActual < vDiferencia) then begin
                    vLinea := RecWhseReceiptLine."Line No.";
                    vDiferencia := vDiferenciaActual;
                END;

            end;
        until ((RecWhseReceiptLine.Next() = 0));



        if (vEncontrado) then begin

            //Añadir Nº Albarán a la cabecera de la recepción
            clear(RecWhseReceiptHeader);
            RecWhseReceiptHeader.SetRange("No.", jRecepcion);
            if not RecWhseReceiptHeader.FindFirst() then Error(StrSubstNo(lblErrorRecepcion, jRecepcion));
            RecWhseReceiptHeader."Vendor Shipment No." := jAlbaran;
            RecWhseReceiptHeader.Modify();

            //Se coge la línea
            clear(RecWhseReceiptLine);
            RecWhseReceiptLine.RESET();
            RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
            RecWhseReceiptLine.SETRANGE("Item No.", jReferencia);
            RecWhseReceiptLine.SETRANGE("Line No.", vLinea);
            if not RecWhseReceiptLine.FindFirst() then Error(lblErrorAlRecepcionar);

            //Poner cantidad
            RecWhseReceiptLine.Validate("Qty. to Receive", RecWhseReceiptLine."Qty. to Receive" + jUnidades);
            RecWhseReceiptLine.MODIFY();

            xTipoSeguimiento := TipoSeguimientoProducto(jReferencia);
            case xTipoSeguimiento of
                0://Sin Seguimiento
                    begin
                        if (RecWhseSetup."Lote Interno Obligatorio") then Error(StrSubstNo(lblErrorCodSeguimiento, jReferencia));
                    end;
                1://Lote
                    begin
                        if (NOT RecWhseSetup."Lote Automatico") then begin
                            jLote := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (jLote = '') THEN ERROR(lblErrorLote);
                                xContenedor := jLote;
                            END;
                        end;
                        Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                        Crear_Reserva(xContenedor, '', jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                    end;
                2://Serie
                    begin
                        if (RecWhseSetup."Lote Interno Obligatorio") then begin
                            ERROR(lblErrorSegProd);
                        end;
                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva('', jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;
                3://Lote y Serie
                    begin
                        if (NOT RecWhseSetup."Lote Automatico") then begin
                            jLote := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (jLote = '') THEN ERROR(lblErrorLote);
                                xContenedor := jLote;
                            END;
                        end;

                        jMultiSerie := DatoJsonBoolean(VJsonObjectContenedor, 'Multiserie');

                        if jMultiSerie then begin
                            jUnidades := 1;
                            vArraySeries := DatoArrayJsonTexto(VJsonObjectContenedor, 'ObcSeries');
                            foreach vTokenSerie in vArraySeries do begin
                                vJsonObjectSerie := vTokenSerie.AsObject();
                                jSerie := DatoJsonTexto(vJsonObjectSerie, 'SerialNo');
                                Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                                Crear_Reserva(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                            end;
                        end else begin
                            Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            jSerie := DatoJsonTexto(VJsonObjectContenedor, 'SerialNo');
                            Crear_Serie(jSerie, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                            Crear_Reserva(xContenedor, jSerie, jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);
                        end;

                    end;
                4://Lote y Paquete
                    begin
                        if (NOT RecWhseSetup."Lote Automatico") then begin
                            jLote := DatoJsonTexto(VJsonObjectContenedor, 'LotNo');
                            jLotePreasignado := DatoJsonTexto(VJsonObjectContenedor, 'LotNoPre');
                            if (jLotePreasignado <> '') THEN
                                xContenedor := jLotePreasignado
                            ELSE BEGIN
                                IF (jLote = '') THEN ERROR(lblErrorLote);
                                xContenedor := jLote;
                            END;
                        end;
                        Crear_Lote(xContenedor, jReferencia, jUnidades, jAlbaran, jLoteProveedor);
                        Crear_Reserva(xContenedor, '', jPaquete, jReferencia, jUnidades, jAlbaran, jLoteProveedor, RecWhseReceiptLine, xTipoSeguimiento, FechaCaducidad);

                    end;
                5://Serie y Paquete
                    begin

                    end;
                6://Lote, Serie y Paquete
                    begin

                    end;



            end;


        end;


        IF jEnAlerta THEN BEGIN
            if (jSerie <> '') then begin
                Clear(RecSerie);
                RecSerie.SetRange("Item No.", jReferencia);
                RecSerie.SetRange("Serial No.", jSerie);
                if RecSerie.FindFirst() then begin
                    jText := DatoJsonTexto(VJsonObjectContenedor, 'AlertText');
                    jFoto := DatoJsonTexto(VJsonObjectContenedor, 'AlertPhoto');
                    If (jFoto <> '') THEN BEGIN

                        NombreFoto := 'A-' + jSerie + '.jpg';

                        cuTempBlob.CreateOutStream(oStream);
                        cuBase64.FromBase64(jFoto, oStream);

                        cuTempBlob.CreateInStream(iStream);
                        Clear(RecSerie.Foto);
                        RecSerie.Foto.ImportStream(iStream, NombreFoto);

                    END;
                    RecSerie.Alerta := jText;
                    RecSerie.Modify();
                end;
            end else begin
                if (xContenedor <> '') then begin
                    Clear(RecLote);
                    RecLote.SetRange("Item No.", jReferencia);
                    RecLote.SetRange("Lot No.", xContenedor);
                    if RecLote.FindFirst() then begin
                        jText := DatoJsonTexto(VJsonObjectContenedor, 'AlertText');
                        jFoto := DatoJsonTexto(VJsonObjectContenedor, 'AlertPhoto');
                        If (jFoto <> '') THEN BEGIN

                            NombreFoto := 'A-' + xContenedor + '.jpg';

                            cuTempBlob.CreateOutStream(oStream);
                            cuBase64.FromBase64(jFoto, oStream);

                            cuTempBlob.CreateInStream(iStream);
                            Clear(RecLote.Foto);
                            RecLote.Foto.ImportStream(iStream, NombreFoto);

                        END;
                        RecLote.Alerta := jText;
                        RecLote.Modify();
                    end;
                end;
            end;
        END;



        //Imprimir etiqueta
        Clear(RecResource);
        RecResource.SetRange("No.", jRecurso);
        IF NOT RecResource.FindFirst() then ERROR(lblErrorRecurso);

        /*if jImprimir and not xOmitirImpresion then
            Imprimir_Componente(RecResource."Printer Name", 1, lReferencia, xContenedor);*/

    end;

    local procedure Vaciar_Cantidad_Recibir(xRecepcion: Text)
    var
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SetRange("No.", xRecepcion);
        if RecWhseReceiptLine.FindSet() then
            repeat
                RecWhseReceiptLine.Validate("Qty. to Receive", 0);
                RecWhseReceiptLine.Modify();
            until RecWhseReceiptLine.Next() = 0;

    end;

    local procedure Crear_Lote(xLotNo: Text; xItemNo: Text; xQuantity: Decimal; xAlbaran: Text; xVendorLotNo: Text)
    var
        RecLote: Record "Lot No. Information";
        RecItem: Record Item;
    begin

        RecItem.Get(xItemNo);

        Clear(RecLote);
        RecLote.SetRange("Lot No.", xLotNo);
        RecLote.SetRange("Item No.", xItemNo);
        if NOT RecLote.FindFirst() then BEGIN

            RecLote.init;

            RecLote."Item No." := xItemNo;
            RecLote."Lot No." := xLotNo;
            RecLote.Description := RecItem.Description;
            RecLote."Fecha Recepcion" := TODAY();
            RecLote."Albaran Proveedor" := xAlbaran;
            if (xVendorLotNo <> '') then
                RecLote."Lote Proveedor" := xVendorLotNo
            else
                RecLote."Lote Proveedor" := xAlbaran;

            RecLote.INSERT;

        end;
    end;


    local procedure Crear_Serie(xSerialNo: Text; xItemNo: Text; xQuantity: Decimal; xAlbaran: Text; xVendorLotNo: Text)
    var
        RecSerie: Record "Serial No. Information";
        RecItem: Record Item;
    begin

        RecItem.Get(xItemNo);

        Clear(RecSerie);
        RecSerie.SetRange("Serial No.", xSerialNo);
        if NOT RecSerie.FindFirst() then BEGIN

            RecSerie.init;

            RecSerie."Item No." := xItemNo;
            RecSerie."Serial No." := xSerialNo;
            RecSerie.Description := RecItem.Description;

            RecSerie."Fecha Recepcion" := TODAY();
            RecSerie."Albaran Proveedor" := xAlbaran;
            if (xVendorLotNo <> '') then
                RecSerie."Lote Proveedor" := xVendorLotNo
            else
                RecSerie."Lote Proveedor" := xAlbaran;

            RecSerie.INSERT;

        end else begin
            ERROR(lblErrorSerialDuplicado);
        end;
    end;


    local procedure Crear_Reserva(xLotNo: Text; xSerialNo: Text; xPackageNo: Text; xItemNo: Text; xQuantity: Decimal; xAlbaran: Text; xVendorLotNo: Text; xRecWhseReceiptLine: Record "Warehouse Receipt Line"; xTipoSeguimiento: Integer; xFechaCaducidad: Date)
    var
        RecReservationEntry: Record "Reservation Entry";
        vNumReserva: Integer;

    begin
        //Crear la reserva
        Clear(RecReservationEntry);
        if RecReservationEntry.FindLast() then
            vNumReserva := RecReservationEntry."Entry No." + 1
        else
            vNumReserva := 1;
        Clear(RecReservationEntry);

        RecReservationEntry.Init();

        RecReservationEntry."Entry No." := vNumReserva;
        RecReservationEntry.Positive := TRUE;
        RecReservationEntry.validate("Item No.", xItemNo);
        RecReservationEntry."Location Code" := xRecWhseReceiptLine."Location Code";
        RecReservationEntry."Quantity (Base)" := xQuantity;
        RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Surplus;
        RecReservationEntry."Creation Date" := WORKDATE;
        RecReservationEntry."Source Type" := 39;
        RecReservationEntry."Source Subtype" := 1;
        RecReservationEntry."Source ID" := xRecWhseReceiptLine."Source No.";
        RecReservationEntry."Source Ref. No." := xRecWhseReceiptLine."Source Line No.";
        RecReservationEntry."Expected Receipt Date" := WORKDATE;
        RecReservationEntry."Created By" := USERID;
        RecReservationEntry."Qty. per Unit of Measure" := xRecWhseReceiptLine."Qty. per Unit of Measure";
        RecReservationEntry.Quantity := xQuantity;
        RecReservationEntry."Qty. to Handle (Base)" := xQuantity;
        RecReservationEntry."Qty. to Invoice (Base)" := xQuantity;

        case xTipoSeguimiento of
            0://Sin Seguimiento
                begin
                end;
            1://Lote
                begin
                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot No.";
                end;
            2://Serie
                begin
                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Serial No.";
                end;
            3://Lote y Serie
                begin
                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Serial No.";
                end;
            4://Lote y Paquete
                begin
                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Package No.";
                end;
            5://Serie y Paquete
                begin
                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Serial and Package No.";
                end;
            6://Lote, Serie y Paquete
                begin
                    RecReservationEntry."Lot No." := xLotNo;
                    RecReservationEntry."Serial No." := xSerialNo;
                    RecReservationEntry."Package No." := xPackageNo;
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot and Serial and Package No.";
                end;
        end;

        if (xFechaCaducidad <> 0D) THEN
            RecReservationEntry."Expiration Date" := xFechaCaducidad;

        RecReservationEntry.INSERT;
    end;


    local procedure Eliminar_Contenedor_Recepcion(xJson: Text)
    var

        RecReservationEntry: Record "Reservation Entry";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecLotNoInf: Record "Lot No. Information";
        RecPurchaseLine: Record "Purchase Line";
        VJsonObjectContenedor: JsonObject;

        lParte: Text;
        VJsonText: Text;
        lNumeroContenedor: Text;
        lRespuesta: Text;
        jRecepcion: Text;
        jLineNo: Integer;
        jEntryNo: Integer;

        jLoteInterno: Text;
        jSerie: Text;
        EsSubcontratacion: Boolean;
    begin
        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLineNo := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');
        jEntryNo := DatoJsonInteger(VJsonObjectContenedor, 'EntryNo');

        CLEAR(RecReservationEntry);
        RecReservationEntry.SetRange("Entry No.", jEntryNo);
        IF NOT RecReservationEntry.FindFirst() THEN Error(StrSubstNo(lblErrorLoteInternoNoExiste, ''));

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
        RecWhseReceiptLine.SETRANGE("Line No.", jLineNo);
        IF RecWhseReceiptLine.findfirst THEN begin
            RecWhseReceiptLine.Validate("Qty. to Receive", RecWhseReceiptLine."Qty. to Receive" - RecReservationEntry.Quantity);
            if (RecWhseReceiptLine."Qty. to Receive" < 0) then
                RecWhseReceiptLine.Validate("Qty. to Receive", 0);
            RecWhseReceiptLine.MODIFY();
        end;

        RecReservationEntry.Delete();


        //Eliminar el lote si no está en algún pedido de compra preasignado
        /*Clear(RecPurchaseLine);
        RecPurchaseLine.SetRange("Lote preasignado", lContenedor);
        IF NOT RecPurchaseLine.FindFirst() THEN begin
            clear(RecLotNoInf);
            RecLotNoInf.SetRange("Lot No.", lContenedor);
            if RecLotNoInf.FindFirst() then
                RecLotNoInf.Delete();
        end;*/


        /*if (EsSubcontratacion) then begin
            Actualizar_Cantidad_Recibir_Subcontratacion(lRecepcion);
            Objeto_Recepcion_Sub(lRecepcion).WriteTo(VJsonText);
        end else begin
            Actualizar_Cantidad_Recibir(lRecepcion);
            Objeto_Recepcion(lRecepcion).WriteTo(VJsonText);
        end;*/




    end;

    local procedure Eliminar_Cantidad_Recepcion(xJson: Text)
    var

        RecReservationEntry: Record "Reservation Entry";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        RecLotNoInf: Record "Lot No. Information";
        RecPurchaseLine: Record "Purchase Line";
        VJsonObjectContenedor: JsonObject;

        lParte: Text;
        VJsonText: Text;
        lNumeroContenedor: Text;
        lRespuesta: Text;
        jRecepcion: Text;
        jLineNo: Integer;
        jLoteInterno: Text;
        jSerie: Text;
        EsSubcontratacion: Boolean;
    begin


        If not VJsonObjectContenedor.ReadFrom(xJson) then
            Error(lblErrorJson);

        jRecepcion := DatoJsonTexto(VJsonObjectContenedor, 'No');
        jLineNo := DatoJsonInteger(VJsonObjectContenedor, 'LineNo');

        CLEAR(RecReservationEntry);
        RecReservationEntry.SetRange("Source ID", jRecepcion);
        RecReservationEntry.SetRange("Source Ref. No.", jLineNo);
        IF RecReservationEntry.FINDSET() THEN RecReservationEntry.DELETEALL();

        clear(RecWhseReceiptLine);
        RecWhseReceiptLine.SETRANGE("No.", jRecepcion);
        RecWhseReceiptLine.SETRANGE("Line No.", jLineNo);
        IF RecWhseReceiptLine.findfirst THEN begin
            RecWhseReceiptLine.Validate("Qty. to Receive", 0);
            RecWhseReceiptLine.MODIFY();
        end;

    end;

    local procedure Registrar_Recepcion(xRecepcion: Text; xLinea: Integer)
    var
        pgWR: Page "Warehouse Receipt";
        RecWhseReceiptLine: Record "Warehouse Receipt Line";
        cuWhsePostReceipt: Codeunit "Whse.-Post Receipt";
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecLocation: Record Location;
    begin
        RecWhseReceiptLine.RESET;
        RecWhseReceiptLine.SETRANGE("No.", xRecepcion);

        if (xLinea > 0) then
            RecWhseReceiptLine.SETRANGE(RecWhseReceiptLine."Line No.", xLinea);

        IF RecWhseReceiptLine.FindSet() THEN BEGIN

            RecLocation.Get(RecWhseReceiptLine."Location Code");
            //Comprobar si está definida las ubicación de recepción en el caso de almacenamiento automático
            if RecLocation."Almacenamiento automatico" then BEGIN
                if RecLocation."Ubicacion Recepcionados" = '' then ERROR('No se ha definido ubicación de recepcionados');
                if RecLocation."Zona Recepcionados" = '' then ERROR('No se ha definido zona de recepcionados');
            END;

            if not cuWhsePostReceipt.RUN(RecWhseReceiptLine) then
                ERROR(lblErrorRegistrar);



            if RecLocation."Almacenamiento automatico" then
                Registrar_Almacenamiento(xRecepcion);

            Vaciar_Cantidad_Recibir(xRecepcion);

        END ELSE
            Error(lblErrorRegistrar);


    end;

    procedure Registrar_Almacenamiento(xRecepcion: Text)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecRecepRegistradas: Record "Posted Whse. Receipt Header";
        RecLocation: Record Location;
        ZonaRecepcionados: Code[20];
        UbicacionRecepcionados: Code[20];

        cuWarehouseActivityRegister: Codeunit "Whse.-Activity-Register";
        RecBin: Record Bin;
        VJsonObjectDatos: JsonObject;

        lResource: Text;

    begin

        Clear(RecRecepRegistradas);
        RecRecepRegistradas.SetRange(RecRecepRegistradas."Whse. Receipt No.", xRecepcion);
        if NOT RecRecepRegistradas.FindLast() then ERROR('No se ha registrado correctamente la recepción %1', xRecepcion);

        RecLocation.Get(RecRecepRegistradas."Location Code");


        if RecLocation."Ubicacion Recepcionados" = '' then ERROR('No se ha definido ubicación de recepcionados');
        if RecLocation."Zona Recepcionados" = '' then ERROR('No se ha definido zona de recepcionados');

        UbicacionRecepcionados := RecLocation."Ubicacion Recepcionados";
        ZonaRecepcionados := RecLocation."Zona Recepcionados";

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("Whse. Document No.", RecRecepRegistradas."No.");
        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
        RecWarehouseActivityLine.SetRange("Activity Type", RecWarehouseActivityLine."Activity Type"::"Put-away");
        if RecWarehouseActivityLine.FindSet() then
            repeat
                //RecWarehouseActivityLine.Resource := lResource;
                RecWarehouseActivityLine.VALIDATE(RecWarehouseActivityLine."Zone Code", ZonaRecepcionados);
                RecWarehouseActivityLine.VALIDATE(RecWarehouseActivityLine."Bin Code", UbicacionRecepcionados);
                RecWarehouseActivityLine.Modify();
            until RecWarehouseActivityLine.Next() = 0;

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("Whse. Document No.", RecRecepRegistradas."No.");
        RecWarehouseActivityLine.SetRange("Activity Type", RecWarehouseActivityLine."Activity Type"::"Put-away");
        if RecWarehouseActivityLine.FindSet() then
            cuWarehouseActivityRegister.run(RecWarehouseActivityLine);

    end;



    /*procedure Crear_Almacenamiento(xReceiptNo: Code[20])
    var
        CreatePutAwayFromWhseSource: Report "Whse.-Source - Create Document";
        PostedWhseRcptLine: Record "Posted Whse. Receipt Line";
        HideValidationDialog: Boolean;
    begin

        Commit();

        HideValidationDialog := true;

        PostedWhseRcptLine.SetFilter("Whse. Receipt No.", xReceiptNo);  //Whse. Receipt No.
        PostedWhseRcptLine.SetFilter(Quantity, '>0');
        PostedWhseRcptLine.SetFilter(
          Status, '<>%1', PostedWhseRcptLine.Status::"Completely Put Away");
        if PostedWhseRcptLine.Find('-') then begin
            CreatePutAwayFromWhseSource.SetPostedWhseReceiptLine(PostedWhseRcptLine, '');
            CreatePutAwayFromWhseSource.SetHideValidationDialog(HideValidationDialog);
            CreatePutAwayFromWhseSource.UseRequestPage(not HideValidationDialog);
            CreatePutAwayFromWhseSource.RunModal();
            CreatePutAwayFromWhseSource.GetResultMessage(1);
            Clear(CreatePutAwayFromWhseSource);
        end else
            if not HideValidationDialog then
                Error(lblErrorNadaQueRegistrar);
    end;*/

    #endregion

    #region INFORMACION

    procedure Contenidos_Ubicacion(xItemNo: Text; xZone: Text; xBin: Text; xLocation: Text; xTipoDato: Code[1]; xDato: Text): JsonArray
    var

        RecContenedores: Record "Lot No. Information";
        RecLotNoInf: Record "Lot No. Information";
        RecBinContent: Record "Bin Content";
        RecItem: Record Item;

        QueryLotInventory: Query "Lot Numbers by Bin";

        VJsonObjectContenido: JsonObject;
        VJsonArrayContenido: JsonArray;
        VJsonObjectContenedor: JsonObject;
        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        VJsonText: Text;
        xNuevoItem: Text;

        iTipoTrack: Integer;

        iTipoDato: Code[1];
    begin


        Clear(RecBinContent);
        RecBinContent.SetRange("Location Code", xLocation);

        if (xTipoDato = 'L') THEN
            RecBinContent.SetRange(RecBinContent."Lot No. Filter", xDato);
        if (xTipoDato = 'S') THEN
            RecBinContent.SetRange(RecBinContent."Serial No. Filter", xDato);
        if (xTipoDato = 'P') THEN
            RecBinContent.SetRange(RecBinContent."Package No. Filter", xDato);

        if (xItemNo <> '') then begin

            Clear(RecItem);
            RecItem.SetRange("No.", xItemNo);
            if NOT RecItem.FindFirst() THEN begin
                xNuevoItem := Buscar_Referencia_Cruzada(xItemNo, '');
                if (xNuevoItem = '') then Error(StrSubstNo(lblErrorReferencia, xItemNo));
                xItemNo := xNuevoItem;

            end;

            RecBinContent.SetFilter(RecBinContent."Item No.", '=%1', xItemNo);

        end;

        if (xBin <> '') then
            RecBinContent.SetFilter(RecBinContent."Bin Code", '=%1', xBin);

        if (xZone <> '') then
            RecBinContent.SetFilter(RecBinContent."Zone Code", '=%1', xZone);

        RecBinContent.SetFilter(RecBinContent.Quantity, '>0');

        if RecBinContent.findset then begin
            repeat

                RecBinContent.CalcFields(RecBinContent.Quantity);
                VJsonObjectContenido.Add('Zone', RecBinContent."Zone Code");
                VJsonObjectContenido.Add('Bin', RecBinContent."Bin Code");
                VJsonObjectContenido.Add('ItemNo', RecBinContent."Item No.");
                VJsonObjectContenido.Add('Description', Descripcion_ItemNo(RecBinContent."Item No."));
                VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(RecBinContent."Item No.")));
                VJsonObjectContenido.Add('BinInventory', FormatoNumero(RecBinContent.Quantity));

                //Inventario por ubicación
                Clear(QueryLotInventory);
                QueryLotInventory.SetFilter(QueryLotInventory.Item_No, '=%1', RecBinContent."Item No.");
                QueryLotInventory.SetFilter(QueryLotInventory.Bin_Code, '=%1', RecBinContent."Bin Code");
                QueryLotInventory.SetFilter(QueryLotInventory.Sum_Qty_Base, '>0');

                if (xTipoDato = 'L') THEN
                    QueryLotInventory.SetRange(QueryLotInventory.Lot_No, xDato);
                if (xTipoDato = 'S') THEN
                    QueryLotInventory.SetRange(QueryLotInventory.Serial_No, xDato);
                if (xTipoDato = 'P') THEN
                    QueryLotInventory.SetRange(QueryLotInventory.Package_No, xDato);

                QueryLotInventory.Open();
                WHILE QueryLotInventory.READ DO BEGIN
                    VJsonObjectInventario.Add('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectInventario.Add('LotNo', QueryLotInventory.Lot_No);
                    VJsonObjectInventario.Add('SerialNo', QueryLotInventory.Serial_No);

                    iTipoTrack := TipoSeguimientoProducto(QueryLotInventory.Item_No);

                    case iTipoTrack of
                        0:
                            begin
                                VJsonObjectInventario.Add('TrackNo', '');
                                VJsonObjectInventario.Add('TipoTrack', 'I');
                            end;
                        2, 3, 5, 6:
                            begin
                                VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Serial_No);
                                VJsonObjectInventario.Add('TipoTrack', 'S');
                            end;
                        1, 4:
                            begin
                                VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Lot_No);
                                VJsonObjectInventario.Add('TipoTrack', 'L');
                            end;

                    end;

                    VJsonObjectInventario.Add('Zone', QueryLotInventory.Zone_Code);
                    VJsonObjectInventario.Add('Bin', QueryLotInventory.Bin_Code);
                    VJsonObjectInventario.Add('BinInventory', FormatoNumero(QueryLotInventory.Sum_Qty_Base));
                    VJsonObjectInventario.Add('Unit', QueryLotInventory.Unit_of_Measure_Code);

                    VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
                    Clear(VJsonObjectInventario);
                END;

                VJsonObjectContenido.Add('Lots', VJsonArrayInventario);

                Clear(VJsonObjectInventario);
                Clear(VJsonArrayInventario);

                QueryLotInventory.Close();

                VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
                Clear(VJsonObjectContenido);

            until RecBinContent.Next() = 0;

        end;




        //VJsonArrayContenido.WriteTo(VJsonText);
        //exit(VJsonText);

        exit(VJsonArrayContenido);

    end;


    procedure Contenidos_Sin_Ubicacion(xItemNo: Text; xLocation: Text; xTipoDato: Code[1]; xDato: Text): Text
    var

        RecContenedores: Record "Lot No. Information";
        RecLotNoInf: Record "Lot No. Information";
        RecItem: Record Item;

        QueryLotInventory: Query "Lot Numbers by Location 2";

        VJsonObjectContenido: JsonObject;
        VJsonArrayContenido: JsonArray;
        VJsonObjectContenedor: JsonObject;
        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        xItemAnt: Text;

        VJsonText: Text;
        xNuevoItem: Text;

        SumQty: Decimal;
        iTipoTrack: Integer;
    begin

        xItemAnt := '';
        SumQty := 0;

        //Inventario por mov. producto
        Clear(QueryLotInventory);

        QueryLotInventory.SetFilter(QueryLotInventory.Location_Code, '=%1', xLocation);

        if (xTipoDato = 'N') THEN
            ERROR(lblErrorTrackNo);
        if (xTipoDato = 'L') THEN
            QueryLotInventory.SetRange(QueryLotInventory.Lot_No, xDato);
        if (xTipoDato = 'S') THEN
            QueryLotInventory.SetRange(QueryLotInventory.Serial_No, xDato);
        if (xTipoDato = 'P') THEN
            QueryLotInventory.SetRange(QueryLotInventory.Package_No, xDato);
        if (xTipoDato = 'I') THEN
            QueryLotInventory.SetFilter(QueryLotInventory.Item_No, '=%1', xItemNo);


        QueryLotInventory.SetFilter(QueryLotInventory.Sum_Qty, '>0');

        QueryLotInventory.Open();
        WHILE QueryLotInventory.READ DO BEGIN

            if (xItemAnt <> QueryLotInventory.Item_No) then begin

                IF (xItemAnt <> '') THEN begin
                    VJsonObjectContenido.Add('Zone', '');
                    VJsonObjectContenido.Add('Bin', '');
                    VJsonObjectContenido.Add('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(QueryLotInventory.Item_No)));
                    VJsonObjectContenido.Add('Description', Descripcion_ItemNo(QueryLotInventory.Item_No));
                    VJsonObjectContenido.Add('BinInventory', FormatoNumero(SumQty));
                    VJsonObjectContenido.Add('Lots', VJsonArrayInventario);
                    VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
                    Clear(VJsonObjectContenido);
                end;

                xItemAnt := QueryLotInventory.Item_No;

                iTipoTrack := TipoSeguimientoProducto(QueryLotInventory.Item_No);

            end;
            VJsonObjectInventario.Add('ItemNo', QueryLotInventory.Item_No);
            VJsonObjectInventario.Add('LotNo', QueryLotInventory.Lot_No);
            VJsonObjectInventario.Add('SerialNo', QueryLotInventory.Serial_No);

            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
            case iTipoTrack of
                0:
                    begin
                        VJsonObjectInventario.Add('TrackNo', '');
                        VJsonObjectInventario.Add('TipoTrack', 'I');
                    end;
                2, 3, 5, 6:
                    begin
                        VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Serial_No);
                        VJsonObjectInventario.Add('TipoTrack', 'S');
                    end;
                1, 4:
                    begin
                        VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Lot_No);
                        VJsonObjectInventario.Add('TipoTrack', 'L');
                    end;

            end;


            VJsonObjectInventario.Add('Zone', '');
            VJsonObjectInventario.Add('Bin', '');
            VJsonObjectInventario.Add('BinInventory', FormatoNumero(QueryLotInventory.Sum_Qty));
            VJsonObjectInventario.Add('Unit', QueryLotInventory.Unit_of_Measure_Code);

            SumQty += QueryLotInventory.Sum_Qty;

            VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
            Clear(VJsonObjectInventario);

        end;

        IF (xItemAnt <> '') THEN begin
            VJsonObjectContenido.Add('Zone', '');
            VJsonObjectContenido.Add('Bin', '');
            VJsonObjectContenido.Add('ItemNo', xItemAnt);
            VJsonObjectContenido.Add('Tipo', FormatoNumero(TipoSeguimientoProducto(xItemAnt)));
            VJsonObjectContenido.Add('Description', Descripcion_ItemNo(xItemAnt));
            VJsonObjectContenido.Add('BinInventory', FormatoNumero(SumQty));
            VJsonObjectContenido.Add('Lots', VJsonArrayInventario);
            VJsonArrayContenido.Add(VJsonObjectContenido.Clone());
            Clear(VJsonObjectContenido);
        end;


        QueryLotInventory.Close();


        VJsonArrayContenido.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    #endregion

    #region MOVER


    /// <summary>
    /// Tipo_Trazabilidad.
    /// </summary>
    /// <param name="xTrackNo">Text.</param>
    /// <returns>L:Lote S:Serie P:Paquete N:Nada</returns>
    local procedure Tipo_Trazabilidad(xTrackNo: Text): Code[1]
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPaquete: Record "Package No. Information";
        RecItem: Record Item;
    begin
        Clear(RecLotNo);
        RecLotNo.SetRange("Lot No.", xTrackNo);
        if RecLotNo.FindFirst() then exit('L');

        Clear(RecSerialNo);
        RecSerialNo.SetRange("Serial No.", xTrackNo);
        if RecSerialNo.FindFirst() then exit('S');

        Clear(RecPaquete);
        RecPaquete.SetRange("Package No.", xTrackNo);
        if RecPaquete.FindFirst() then exit('P');

        Clear(RecItem);
        RecItem.SetRange("No.", xTrackNo);
        if RecItem.FindFirst() then exit('I');

        exit('N');


    end;


    procedure AppCreateReclassWarehouse_Avanzado(xLocation: Text; xFromBin: code[20]; xToBin: code[20]; xQty: decimal; xTrackNo: code[20]; xResourceNo: code[20]; xItemNo: code[20]; xLotNo: Text; xSerialNo: Text; xPackageNo: Text; newPackageNo: Text);
    var
        RecLocation: Record Location;
        WhseJnlTemplate: record "Warehouse Journal Template";
        WhseJnlLine: record "Warehouse Journal Line";
        WhseJnlLineLast: record "Warehouse Journal Line";
        RecBin: Record Bin;

        WhseItemTrackingLine: record "Whse. Item Tracking Line";
        WhseItemTrackingLineLast: record "Whse. Item Tracking Line";
        LineNo: Integer;

        sTipo: Integer;


        WhseJnlRegisterLine: codeunit "Whse. Jnl.-Register Line";

        lblErrorReclasif: Label 'Not exist Reclassification Template', comment = 'ESP="No existe Libro diario Reclasificación"';
    begin

        Clear(RecLocation);
        RecLocation.Get(xLocation);

        if (RecLocation.AppJournalTemplateName) = '' then Error(lblErrorReclasif);
        if (RecLocation.AppJournalBatchName) = '' then Error(lblErrorReclasif);


        WhseJnlTemplate.reset;
        WhseJnlTemplate.setrange(Type, WhseJnlTemplate.Type::Reclassification);
        if not WhseJnlTemplate.findset then
            error(lblErrorReclasif);

        WhseJnlLine.RESET;
        WhseJnlLine.SETRANGE("Journal Template Name", RecLocation.AppJournalTemplateName);
        WhseJnlLine.SETRANGE("Journal Batch Name", RecLocation.AppJournalBatchName);
        IF WhseJnlLine.findset then
            repeat
                WhseJnlLine.delete;
            until WhseJnlLine.Next = 0;

        Clear(RecBin);
        RecBin.SetRange(Code, xFromBin);
        IF NOT RecBin.FindFirst() THEN Error(StrSubstNo(lblErrorUbicacion, xFromBin));

        LineNo := 10001;
        WhseJnlLineLast.Reset;
        WhseJnlLineLast.setrange("Journal Template Name", RecLocation.AppJournalTemplateName);
        WhseJnlLineLast.setrange("Journal Batch Name", RecLocation.AppJournalBatchName);
        WhseJnlLineLast.setrange("Location Code", RecBin."Location Code");
        if WhseJnlLineLast.findlast then
            LineNo := WhseJnlLineLast."Line No." + 10000;

        WhseJnlLine.init;
        WhseJnlLine."Journal Template Name" := RecLocation.AppJournalTemplateName;
        WhseJnlLine."Journal Batch Name" := RecLocation.AppJournalBatchName;
        WhseJnlLine.validate("Location Code", RecBin."Location Code");
        WhseJnlLine."Line No." := LineNo;
        WhseJnlLine.validate("Registering Date", workdate);
        WhseJnlLine.insert;
        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
        WhseJnlLine."Source Code" := 'DIARECLALM';
        WhseJnlLine.validate("Item No.", xItemNo);
        WhseJnlLine.validate("From Zone Code", RecBin."Zone Code");
        WhseJnlLine.validate("From Bin Code", xFromBin);

        Clear(RecBin);
        RecBin.SetRange(Code, xToBin);
        IF NOT RecBin.FindFirst() THEN Error(StrSubstNo(lblErrorUbicacion, xToBin));


        WhseJnlLine.validate("To Zone Code", RecBin."Zone Code");
        WhseJnlLine.validate("To Bin Code", xToBin);
        WhseJnlLine.validate(Quantity, xQty);
        WhseJnlLine."Whse. Document No." := 'MOVE';
        //WhseJnlLine.Resource := Resource;

        WhseJnlLine.modify;


        if (xTrackNo <> '') then begin
            if WhseItemTrackingLineLast.findlast then;
            WhseItemTrackingLine.init;
            WhseItemTrackingLine."Entry No." := WhseItemTrackingLineLast."Entry No." + 1;
            WhseItemTrackingLine."Item No." := WhseJnlLine."Item No.";// xItemNo;
            WhseItemTrackingLine."Location Code" := RecBin."Location Code";
            WhseItemTrackingLine."Quantity (Base)" := xQty;
            WhseItemTrackingLine."Source Type" := 7311;
            WhseItemTrackingLine."Source ID" := RecLocation.AppJournalBatchName;
            WhseItemTrackingLine."Source Batch Name" := RecLocation.AppJournalTemplateName;
            WhseItemTrackingLine."Source Ref. No." := LineNo;
            WhseItemTrackingLine."Qty. per Unit of Measure" := 1;
            WhseItemTrackingLine."Qty. to Handle (Base)" := xQty;
            WhseItemTrackingLine."Qty. to Handle" := xQty; //"Qty. per Unit of Measure"

            sTipo := TipoSeguimientoProducto(xItemNo);
            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>

            if ((sTipo = 1) OR (sTipo = 3) OR (sTipo = 4) or (sTipo = 6)) THEN begin
                WhseItemTrackingLine."New Lot No." := xLotNo;
                WhseItemTrackingLine."Lot No." := xLotNo;
            end;

            if ((sTipo = 2) OR (sTipo = 3) OR (sTipo = 5) or (sTipo = 6)) THEN begin
                WhseItemTrackingLine."Serial No." := xSerialNo;
                WhseItemTrackingLine."New Serial No." := xSerialNo;
            end;

            if ((sTipo = 4) OR (sTipo = 5) OR (sTipo = 6)) THEN begin
                WhseItemTrackingLine."Package No." := xPackageNo;
                WhseItemTrackingLine."New Package No." := newPackageNo;
            end;

            WhseItemTrackingLine.insert;

        end;

        WhseJnlLine.reset;
        WhseJnlLine.SETRANGE("Whse. Document No.", 'MOVE');
        WhseJnlLine.SETRANGE("To Bin Code", '=%1', xToBin);
        IF WhseJnlLine.FindSet() then begin
            //Registrar
            CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register Batch", WhseJnlLine)
        end ELSE
            Error(lblErrorMover);

    end;


    #endregion

    #region PICKING


    procedure Lineas_Picking(xNo: Code[20]; xLocation: Text): Text
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

        RecWarehouseSetup: Record "Warehouse Setup";

        VJsonObjectPicking: JsonObject;
        VJsonArrayPicking: JsonArray;
        VJsonObjectLineas: JsonObject;
        VJsonArrayLineas: JsonArray;

        VJsonText: Text;
        lUbicacionEnvio: Text;

    begin

        RecWarehouseSetup.get();

        Clear(RecWarehouseActivityHeader);
        if xNo <> '' then
            RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."No.", xNo);

        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."Location Code", xLocation);
        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::Pick);
        if RecWarehouseActivityHeader.findset then begin

            VJsonObjectPicking.Add('No', RecWarehouseActivityHeader."No.");
            VJsonObjectPicking.Add('SystemDate', FormatoFecha(RecWarehouseActivityHeader.SystemCreatedAt));

            //VACIAR CANTIDAD A MANIPULAR
            clear(RecWarehouseActivityLine);
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."No.", RecWarehouseActivityHeader."No.");
            //RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."Source Document", RecWarehouseActivityLine."Source Document"::"Sales Order");
            RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Lot No.", '=%1', '');
            IF RecWarehouseActivityLine.FindSet() THEN
                repeat
                    RecWarehouseActivityLine.Validate("Qty. to Handle", 0);
                    RecWarehouseActivityLine.Modify();
                UNTIL RecWarehouseActivityLine.Next() = 0;

            repeat

                clear(RecWarehouseActivityLine);
                RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
                RecWarehouseActivityLine.SetRange("Source Document", RecWarehouseActivityLine."Source Document"::"Sales Order");
                RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Take);
                RecWarehouseActivityLine.SetFilter("Qty. Outstanding", '>%1', RecWarehouseActivityLine."Qty. to Handle");
                if RecWarehouseActivityLine.FindSet() then begin
                    clear(RecWarehouseActivityLineAux);
                    RecWarehouseActivityLineAux.SetRange("No.", RecWarehouseActivityHeader."No.");
                    RecWarehouseActivityLineAux.SetRange("Item No.", RecWarehouseActivityLine."Item No.");
                    RecWarehouseActivityLineAux.SetRange("Source Line No.", RecWarehouseActivityLine."Source Line No.");
                    RecWarehouseActivityLineAux.SetRange("Source Subline No.", RecWarehouseActivityLine."Source Subline No.");
                    RecWarehouseActivityLineAux.SetRange("Action Type", RecWarehouseActivityLineAux."Action Type"::Place);
                    if RecWarehouseActivityLineAux.FindFirst() then
                        lUbicacionEnvio := RecWarehouseActivityLineAux."Bin Code";

                    repeat

                        VJsonObjectLineas.Add('ItemNo', RecWarehouseActivityLine."Item No.");
                        VJsonObjectLineas.Add('Description', Descripcion_ItemNo(RecWarehouseActivityLine."Item No."));
                        VJsonObjectLineas.Add('BinFrom', RecWarehouseActivityLine."Bin Code");
                        VJsonObjectLineas.Add('BinTo', lUbicacionEnvio);
                        VJsonObjectLineas.Add('Quantity', QuitarPunto(Format(RecWarehouseActivityLine.Quantity)));
                        VJsonObjectLineas.Add('QtyToHandle', QuitarPunto(Format(RecWarehouseActivityLine."Qty. to Handle")));

                        VJsonObjectLineas.Add('QtyOutstanding', QuitarPunto(Format(RecWarehouseActivityLine."Qty. Outstanding")));
                        VJsonArrayLineas.Add(VJsonObjectLineas.Clone());

                        clear(VJsonObjectLineas);
                    until RecWarehouseActivityLine.Next() = 0;

                end;

                VJsonObjectPicking.Add('Lines', VJsonArrayLineas.Clone());
                Clear(VJsonArrayLineas);

                VJsonArrayPicking.Add(VJsonObjectPicking.Clone());
                clear(VJsonObjectPicking);

            until RecWarehouseActivityHeader.Next() = 0

        end;

        VJsonArrayPicking.WriteTo(VJsonText);

        exit(VJsonText);

    end;



    #endregion

    #region ALMACENAMIENTO


    procedure Lineas_Almacenamiento(xNo: Code[20]; xLocation: Text): Text
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

        RecWarehouseSetup: Record "Warehouse Setup";

        VJsonObjectAlmto: JsonObject;
        VJsonArrayAlmto: JsonArray;
        VJsonObjectLineas: JsonObject;
        VJsonArrayLineas: JsonArray;

        VJsonText: Text;
        lUbicacionRecepcion: Text;
    begin

        RecWarehouseSetup.get();

        Clear(RecWarehouseActivityHeader);
        if xNo <> '' then
            RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader."No.", xNo);

        RecWarehouseActivityHeader.SetRange("Location Code", xLocation);
        RecWarehouseActivityHeader.SetRange(RecWarehouseActivityHeader.Type, RecWarehouseActivityHeader.Type::"Put-away");
        if RecWarehouseActivityHeader.findset then begin
            repeat

                VJsonObjectAlmto := Objeto_Almacenamiento(RecWarehouseActivityHeader."No.");

                VJsonArrayAlmto.Add(VJsonObjectAlmto.Clone());
                clear(VJsonObjectAlmto);

            until RecWarehouseActivityHeader.Next() = 0

        end;

        VJsonArrayAlmto.WriteTo(VJsonText);

        exit(VJsonText);

    end;

    local procedure Objeto_Almacenamiento(xNo: Code[20]): JsonObject
    var
        RecWarehouseActivityHeader: Record "Warehouse Activity Header";
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

        RecWarehouseSetup: Record "Warehouse Setup";

        VJsonObjectAlmto: JsonObject;
        VJsonObjectLineas: JsonObject;
        VJsonArrayLineas: JsonArray;

        VJsonText: Text;
        lUbicacionRecepcion: Text;
    begin

        CLEAR(VJsonObjectAlmto);

        Clear(RecWarehouseActivityHeader);
        RecWarehouseActivityHeader.SetRange("No.", xNo);
        if RecWarehouseActivityHeader.FindFirst() then BEGIN

            //VACIAR CANTIDAD A MANIPULAR
            /*clear(RecWarehouseActivityLine);
            RecWarehouseActivityLine.SetRange(RecWarehouseActivityLine."No.", xNo);
            RecWarehouseActivityLine.SetFilter(RecWarehouseActivityLine."Lot No.", '=%1', '');
            IF RecWarehouseActivityLine.FindSet() THEN
                repeat
                    RecWarehouseActivityLine.Validate("Qty. to Handle", 0);
                    RecWarehouseActivityLine.Modify();
                UNTIL RecWarehouseActivityLine.Next() = 0;*/

            VJsonObjectAlmto.Add('No', RecWarehouseActivityHeader."No.");
            VJsonObjectAlmto.Add('SystemDate', FormatoFecha(RecWarehouseActivityHeader.SystemCreatedAt));

            clear(RecWarehouseActivityLine);
            RecWarehouseActivityLine.SetRange("No.", RecWarehouseActivityHeader."No.");
            //RecWarehouseActivityLine.SetRange("Source Document", RecWarehouseActivityLine."Source Document"::"Purchase Order");
            RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
            RecWarehouseActivityLine.SetFilter("Qty. Outstanding", '>%1', RecWarehouseActivityLine."Qty. to Handle");
            if RecWarehouseActivityLine.FindSet() then begin
                clear(RecWarehouseActivityLineAux);
                RecWarehouseActivityLineAux.SetRange("No.", RecWarehouseActivityHeader."No.");
                RecWarehouseActivityLineAux.SetRange("Item No.", RecWarehouseActivityLine."Item No.");
                RecWarehouseActivityLineAux.SetRange("Source Line No.", RecWarehouseActivityLine."Source Line No.");
                RecWarehouseActivityLineAux.SetRange("Source Subline No.", RecWarehouseActivityLine."Source Subline No.");
                RecWarehouseActivityLineAux.SetRange("Action Type", RecWarehouseActivityLineAux."Action Type"::Take);
                if RecWarehouseActivityLineAux.FindFirst() then
                    lUbicacionRecepcion := RecWarehouseActivityLineAux."Bin Code";

                repeat
                    VJsonObjectLineas.Add('No', RecWarehouseActivityLine."No.");
                    VJsonObjectLineas.Add('ItemNo', RecWarehouseActivityLine."Item No.");
                    VJsonObjectLineas.Add('Description', Descripcion_ItemNo(RecWarehouseActivityLine."Item No."));
                    VJsonObjectLineas.Add('BinFrom', lUbicacionRecepcion);
                    VJsonObjectLineas.Add('BinTo', RecWarehouseActivityLine."Bin Code");
                    VJsonObjectLineas.Add('LotNo', RecWarehouseActivityLine."Lot No.");
                    VJsonObjectLineas.Add('SerialNo', RecWarehouseActivityLine."Serial No.");
                    VJsonObjectLineas.Add('PackageNo', RecWarehouseActivityLine."Package No.");
                    VJsonObjectLineas.Add('Quantity', QuitarPunto(Format(RecWarehouseActivityLine.Quantity)));
                    VJsonObjectLineas.Add('QtyToHandle', QuitarPunto(Format(RecWarehouseActivityLine."Qty. to Handle")));

                    VJsonObjectLineas.Add('QtyOutstanding', QuitarPunto(Format(RecWarehouseActivityLine."Qty. Outstanding")));
                    VJsonArrayLineas.Add(VJsonObjectLineas.Clone());

                    clear(VJsonObjectLineas);
                until RecWarehouseActivityLine.Next() = 0;

            end ELSE begin
                VJsonObjectAlmto.Add('No', '');
            end;

            VJsonObjectAlmto.Add('Lines', VJsonArrayLineas.Clone());
            Clear(VJsonArrayLineas);

        END;

        exit(VJsonObjectAlmto);
    end;

    local procedure Registrar_Almacenamiento(xNo: Text; xLotNo: Text; xItemNo: Text; jBinTo: Text; xSerialNo: Text; xQuantity: decimal): Text
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        cuWarehouseActivityRegister: Codeunit "Whse.-Activity-Register";

        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);
        if (xLotNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
        if (xSerialNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Serial No.", xSerialNo);

        RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);
        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);
        if RecWarehouseActivityLine.FindFirst() then begin
            RecWarehouseActivityLine.Validate("Bin Code", jBinTo);
            if (RecWarehouseActivityLine."Lot No." = '') then RecWarehouseActivityLine."Lot No." := xLotNo;
            if (RecWarehouseActivityLine."Serial No." = '') then RecWarehouseActivityLine."Serial No." := xSerialNo;
            RecWarehouseActivityLine.Modify();
        end;

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);
        if (xLotNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
        if (xSerialNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Serial No.", xSerialNo);

        RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);
        //RecWarehouseActivityLine.SetFilter("Line No.", '=%1|%2', lLineNoFrom, lLineNoTo);
        if RecWarehouseActivityLine.FindSet() then
            cuWarehouseActivityRegister.run(RecWarehouseActivityLine)
        ELSE
            Error(lblErrorSinAlmacenamiento);

        VJsonObjectAlmacenamiento := Objeto_Almacenamiento(xNo);
        VJsonObjectAlmacenamiento.WriteTo(VJsonText);
        exit(VJsonText);

    end;

    /// <summary>
    /// Registrar_Movimiento.
    /// </summary>
    /// <param name="xNo">Text.</param>
    /// <param name="xDocumentType">Enum "Warehouse Activity Document Type".</param>
    /// <param name="xDocumentNo">Text.</param>
    /// <param name="xDocumentLineNo">Integer.</param>
    /// <param name="xBinTo">Text.</param>
    /// <param name="xQuantity">decimal.</param>
    /// <param name="xItemNo">Text.</param>
    /// <param name="xLotNo">Text.</param>
    /// <param name="xSerialNo">Text.</param>
    local procedure Registrar_Movimiento(xNo: Text; xLineNoTake: Integer; xLineNoPlace: Integer; xDocumentType: Enum "Warehouse Activity Document Type"; xDocumentNo: Text;
                                                                                                                    xDocumentLineNo: Integer;
                                                                                                                    xBinFrom: Text;
                                                                                                                    xBinTo: Text;
                                                                                                                    xQuantity: decimal;
                                                                                                                    xItemNo: Text;
                                                                                                                    xLotNo: Text;
                                                                                                                    xSerialNo: Text)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        cuWarehouseActivityRegister: Codeunit "Whse.-Activity-Register";

        VJsonObjectAlmacenamiento: JsonObject;
        VJsonText: Text;
    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Line No.", xLineNoPlace);
        RecWarehouseActivityLine.SetRange("Whse. Document Type", xDocumentType);
        if (xDocumentNo <> '') then
            RecWarehouseActivityLine.SetRange("Whse. Document No.", xDocumentNo);
        if (xDocumentLineNo <> 0) then
            RecWarehouseActivityLine.SetRange("Whse. Document Line No.", xDocumentLineNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);

        if (xDocumentType <> RecWarehouseActivityLine."Whse. Document Type"::Shipment) then begin
            if (xLotNo <> '') THEN
                RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
            if (xSerialNo <> '') THEN
                RecWarehouseActivityLine.SetRange("Serial No.", xSerialNo);
        end;

        //RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);

        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);

        if RecWarehouseActivityLine.FindFirst() then begin

            RecWarehouseActivityLine.Validate("Qty. to Handle", xQuantity);

            IF RecWarehouseActivityLine."Qty. Outstanding" <> xQuantity THEN BEGIN
                //Dividimos linea
                //RecWarehouseActivityLine.SplitLine(RecWarehouseActivityLine);
                //Place
                Cortar_Linea(xNo, xLineNoTake, xDocumentType, xDocumentNo, xDocumentLineNo, xBinFrom, xBinTo, xQuantity, xItemNo, xLotNo, xSerialNo, false);
                //Take
                Cortar_Linea(xNo, xLineNoTake, xDocumentType, xDocumentNo, xDocumentLineNo, xBinFrom, xBinTo, xQuantity, xItemNo, xLotNo, xSerialNo, true);

            end;

            if (RecWarehouseActivityLine."Whse. Document Type" = RecWarehouseActivityLine."Whse. Document Type"::Shipment) then begin
                if (xLotNo <> '') THEN
                    RecWarehouseActivityLine.Validate("Lot No.", xLotNo);
                if (xSerialNo <> '') THEN
                    RecWarehouseActivityLine.Validate("Serial No.", xSerialNo);

                //Cambiar el lote/serie también el take
                Cambiar_Track_Movimiento_Take(xNo, xLineNoTake, xDocumentType, xDocumentNo, xDocumentLineNo, xBinFrom, xBinTo, xQuantity, xItemNo, xLotNo, xSerialNo);
            end else begin
                RecWarehouseActivityLine.Validate("Bin Code", xBinTo);
            end;
            RecWarehouseActivityLine.Modify();
        end;

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Whse. Document Type", xDocumentType);
        if (xDocumentNo <> '') then
            RecWarehouseActivityLine.SetRange("Whse. Document No.", xDocumentNo);
        if (xDocumentLineNo <> 0) then
            RecWarehouseActivityLine.SetRange("Whse. Document Line No.", xDocumentLineNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);
        if (xLotNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Lot No.", xLotNo);
        if (xSerialNo <> '') THEN
            RecWarehouseActivityLine.SetRange("Serial No.", xSerialNo);

        //RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);
        if RecWarehouseActivityLine.FindSet() then
            cuWarehouseActivityRegister.run(RecWarehouseActivityLine)
        ELSE
            Error(lblErrorSinMovimiento);
    end;


    local procedure Cambiar_Track_Movimiento_Take(xNo: Text; xLineNoTake: Integer; xDocumentType: Enum "Warehouse Activity Document Type"; xDocumentNo: Text;
                                                                                                      xDocumentLineNo: Integer;
                                                                                                      xBinFrom: Text;
                                                                                                      xBinTo: Text;
                                                                                                      xQuantity: decimal;
                                                                                                      xItemNo: Text;
                                                                                                      xLotNo: Text;
                                                                                                      xSerialNo: Text)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Line No.", xLineNoTake);
        RecWarehouseActivityLine.SetRange("Whse. Document Type", xDocumentType);
        if (xDocumentNo <> '') then
            RecWarehouseActivityLine.SetRange("Whse. Document No.", xDocumentNo);
        if (xDocumentLineNo <> 0) then
            RecWarehouseActivityLine.SetRange("Whse. Document Line No.", xDocumentLineNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);

        RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);

        RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Take);

        if RecWarehouseActivityLine.FindFirst() then begin
            RecWarehouseActivityLine.Validate("Bin Code", xBinFrom);
            if (xLotNo <> '') THEN
                RecWarehouseActivityLine.Validate("Lot No.", xLotNo);
            if (xSerialNo <> '') THEN
                RecWarehouseActivityLine.Validate("Serial No.", xSerialNo);
            RecWarehouseActivityLine.Modify();
        end;

    end;


    local procedure Cortar_Linea(xNo: Text; xLineNoTake: Integer; xDocumentType: Enum "Warehouse Activity Document Type"; xDocumentNo: Text;
                                                                                     xDocumentLineNo: Integer;
                                                                                     xBinFrom: Text;
                                                                                     xBinTo: Text;
                                                                                     xQuantity: decimal;
                                                                                     xItemNo: Text;
                                                                                     xLotNo: Text;
                                                                                     xSerialNo: Text;
                                                                                     xEsTake: Boolean)
    var
        RecWarehouseActivityLine: Record "Warehouse Activity Line";
        RecWarehouseActivityLineAux: Record "Warehouse Activity Line";

    begin

        clear(RecWarehouseActivityLine);
        RecWarehouseActivityLine.SetRange("No.", xNo);
        RecWarehouseActivityLine.SetRange("Line No.", xLineNoTake);
        RecWarehouseActivityLine.SetRange("Whse. Document Type", xDocumentType);
        if (xDocumentNo <> '') then
            RecWarehouseActivityLine.SetRange("Whse. Document No.", xDocumentNo);
        if (xDocumentLineNo <> 0) then
            RecWarehouseActivityLine.SetRange("Whse. Document Line No.", xDocumentLineNo);
        RecWarehouseActivityLine.SetRange("Item No.", xItemNo);

        //RecWarehouseActivityLine.SetRange("Qty. to Handle", xQuantity);

        if xEsTake then
            RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Take)
        else
            RecWarehouseActivityLine.SetRange("Action Type", RecWarehouseActivityLine."Action Type"::Place);

        if RecWarehouseActivityLine.FindFirst() then begin
            RecWarehouseActivityLine.Validate("Qty. to Handle", xQuantity);
            RecWarehouseActivityLine.SplitLine(RecWarehouseActivityLine);
            RecWarehouseActivityLine.Modify();
        end;

        RecWarehouseActivityLineAux.Reset();
        RecWarehouseActivityLineAux.SetRange("Activity Type", RecWarehouseActivityLine."Activity Type");
        RecWarehouseActivityLineAux.SetRange("No.", RecWarehouseActivityLine."No.");
        RecWarehouseActivityLineAux.SetRange("Action Type", RecWarehouseActivityLine."Action Type");
        RecWarehouseActivityLineAux.SetRange("Location Code", RecWarehouseActivityLine."Location Code");
        RecWarehouseActivityLineAux.setrange("Item No.", RecWarehouseActivityLine."Item No.");
        RecWarehouseActivityLineAux.setFILTER("Bin Code", '=%1', '');
        if RecWarehouseActivityLineAux.FindFirst() then begin
            RecWarehouseActivityLineAux.Validate("Bin Code", RecWarehouseActivityLine."Bin Code");
            //WarehouseALPutAux.Resource := pRecurso; //PX20221014
            RecWarehouseActivityLineAux.Modify();
        end;


    end;


    #endregion

    #region ENVIOS

    local procedure Objeto_Envio(xNo: code[20]): JsonObject
    var
        RecWhsShipmentLine: Record "Warehouse Shipment Line";
        RecSalesHeader: Record "Sales Header";
        RecItemReference: Record "Item Reference";
        RecWhsShipmentHeader: Record "Warehouse Shipment Header";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecSalesLine: Record "Sales Line";
        RecComentarios: Record "Warehouse Comment Line";
        RecItem: Record Item;
        Comentarios: Text;

        //RecItem: Record Item;
        VJsonObjectShipments: JsonObject;
        VJsonArrayShipments: JsonArray;
        VJsonObjectLines: JsonObject;
        VJsonArrayLines: JsonArray;
        VJsonArrayReservas: JsonArray;

        VJsonText: Text;

        CR: Char;
    begin

        CR := 13;

        RecWarehouseSetup.Get();

        clear(RecWhsShipmentHeader);
        RecWhsShipmentHeader.SetRange("No.", xNo);
        if RecWhsShipmentHeader.FindFirst() then;

        //Actualizar_Cantidad_Enviar(RecWhsShipmentHeader."No.");

        Clear(VJsonObjectShipments);

        VJsonObjectShipments.Add('No', RecWhsShipmentHeader."No.");
        VJsonObjectShipments.Add('Date', FormatoFecha(RecWhsShipmentHeader."Posting Date"));
        VJsonObjectShipments.Add('CustomerName', '');
        VJsonObjectShipments.Add('Status', FORMAT(RecWhsShipmentHeader."Document Status"));
        if (RecWhsShipmentHeader."Document Status" = RecWhsShipmentHeader."Document Status"::"Completely Picked") THEN
            VJsonObjectShipments.Add('CompletelyPicked', 'True')
        ELSE
            VJsonObjectShipments.Add('CompletelyPicked', 'False');

        if ((RecWhsShipmentHeader."Document Status" = RecWhsShipmentHeader."Document Status"::"Partially Picked")
        or (RecWhsShipmentHeader."Document Status" = RecWhsShipmentHeader."Document Status"::"Partially Shipped")) THEN
            VJsonObjectShipments.Add('PartiallyPicked', 'True')
        ELSE
            VJsonObjectShipments.Add('PartiallyPicked', 'False');


        //Comentarios

        Comentarios := '';
        Clear(RecComentarios);
        RecComentarios.SetRange("Table Name", RecComentarios."Table Name"::"Whse. Shipment");
        RecComentarios.SetRange("No.", RecWhsShipmentHeader."No.");
        //RecComentarios.SetRange(RecComentarios."Tipo Comentario", RecComentarios."Tipo Comentario"::APP);
        if RecComentarios.FindSet(false) then begin
            VJsonObjectShipments.Add('TieneComentarios', 'true');
            repeat
                Comentarios += RecComentarios.Comment + '-*-';
            until RecComentarios.Next() = 0;
        END ELSE
            VJsonObjectShipments.Add('TieneComentarios', 'false');

        VJsonObjectShipments.Add('Comentarios', Comentarios);

        Clear(RecWhsShipmentLine);
        RecWhsShipmentLine.SetRange("No.", RecWhsShipmentHeader."No.");

        if RecWhsShipmentLine.FindSet() then begin

            //Buscar el nombre del proveedor                    
            if RecWhsShipmentLine."Source Document" = RecWhsShipmentLine."Source Document"::"Sales Order" then begin
                Clear(RecSalesHeader);
                RecSalesHeader.SetRange("Document Type", RecSalesHeader."Document Type"::Order);
                RecSalesHeader.SetRange("No.", RecWhsShipmentLine."Source No.");
                if RecSalesHeader.FindFirst() then
                    VJsonObjectShipments.Replace('CustomerName', RecSalesHeader."Sell-to Customer Name");

            end;

            repeat
                VJsonObjectLines.Add('No', RecWhsShipmentHeader."No.");
                VJsonObjectLines.Add('LineNo', FormatoNumero(RecWhsShipmentLine."Line No."));

                VJsonObjectLines.Add('SourceNo', RecWhsShipmentLine."Source No.");
                VJsonObjectLines.Add('SourceLineNo', RecWhsShipmentLine."Source Line No.");

                VJsonObjectLines.Add('Reference', RecWhsShipmentLine."Item No.");
                VJsonObjectLines.Add('Description', RecWhsShipmentLine.Description);

                VJsonObjectLines.Add('TipoSeguimimento', Format(TipoSeguimientoProducto(RecWhsShipmentLine."Item No.")));
                VJsonObjectLines.Add('LoteInternoObligatorio', FormatoBoolean(RecWarehouseSetup."Lote Interno Obligatorio"));

                VJsonObjectLines.Add('ItemReference', Buscar_Referencia_Cruzada(RecWhsShipmentLine."Item No.", ''));
                VJsonObjectLines.Add('Outstanding', RecWhsShipmentLine."Qty. Outstanding (Base)");// ."Qty. Outstanding");
                VJsonObjectLines.Add('ToShip', RecWhsShipmentLine."Qty. to Ship (Base)");// ."Qty. to Receive");

                if (RecWhsShipmentLine."Qty. to Ship (Base)" < RecWhsShipmentLine."Qty. Outstanding (Base)") then begin
                    VJsonObjectLines.Add('Complete', false);
                    if (RecWhsShipmentLine."Qty. to Ship (Base)" > 0) then
                        VJsonObjectLines.Add('Partial', true)
                    else
                        VJsonObjectLines.Add('Partial', false);

                end else begin
                    VJsonObjectLines.Add('Complete', true);
                    VJsonObjectLines.Add('Partial', false);
                end;


                //Se busca si tiene lote predefinido
                /*clear(RecPurchaseLine);
                RecPurchaseLine.SetRange("Document No.", RecWhsReceiptLine."Source No.");
                RecPurchaseLine.SetRange("Line No.", RecWhsReceiptLine."Source Line No.");
                if RecPurchaseLine.FindFirst() then
                    VJsonObjectLines.Add('Preasignado', RecPurchaseLine."Lote preasignado")
                else
                    VJsonObjectLines.Add('Preasignado', 'BAD' + RecWhsReceiptLine."Source No." + '--' + RecPurchaseLine."Lote preasignado");
                */

                Clear(VJsonArrayReservas);
                VJsonArrayReservas := Reservas_Envios(RecWhsShipmentLine);
                VJsonObjectLines.Add('Reservations', VJsonArrayReservas);

                VJsonArrayLines.Add(VJsonObjectLines.Clone());
                clear(VJsonObjectLines);

            until RecWhsShipmentLine.Next() = 0;

            VJsonObjectShipments.Add('Lines', VJsonArrayLines);

            Clear(VJsonArrayLines);
            Clear(VJsonObjectLines);

        end;

        exit(VJsonObjectShipments);

    end;

    local procedure Actualizar_Cantidad_Enviar(xEnvio: Text)
    var
        RecWhseShipmentLine: Record "Warehouse Shipment Line";
        RecReservationEntry: Record "Reservation Entry";
        CantidadReservada: Decimal;
    begin

        clear(RecWhseShipmentLine);
        RecWhseShipmentLine.SETRANGE("No.", xEnvio);
        IF RecWhseShipmentLine.FINDSET THEN begin
            RecWhseShipmentLine.Validate("Qty. to Ship", 0);
            RecWhseShipmentLine.MODIFY();
            REPEAT
                CantidadReservada := 0;
                Clear(RecReservationEntry);
                RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
                RecReservationEntry.SETRANGE("Source ID", RecWhseShipmentLine."Source No.");
                RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseShipmentLine."Source Line No.");
                RecReservationEntry.SETRANGE("Item No.", RecWhseShipmentLine."Item No.");
                IF RecReservationEntry.FINDSET THEN
                    REPEAT
                        CantidadReservada := CantidadReservada + (-RecReservationEntry.Quantity);
                    UNTIL RecReservationEntry.NEXT = 0;

                RecWhseShipmentLine.Validate("Qty. to Ship", CantidadReservada / RecWhseShipmentLine."Qty. per Unit of Measure");// ("Qty. to Receive", CantidadReservada);

                RecWhseShipmentLine.MODIFY();
            UNTIL RecWhseShipmentLine.NEXT = 0;
        end;
    end;

    local procedure Reservas_Envios(RecWhseShipmentLine: Record "Warehouse Shipment Line"): JsonArray
    var
        RecReservationEntry: Record "Reservation Entry";
        VJsonObjectReservas: JsonObject;
        VJsonArrayReservas: JsonArray;
    begin
        Clear(RecReservationEntry);
        RecReservationEntry.SetFilter("Item Tracking", '<>%1', RecReservationEntry."Item Tracking"::None);
        RecReservationEntry.SETRANGE("Source ID", RecWhseShipmentLine."Source No.");
        RecReservationEntry.SETRANGE("Source Ref. No.", RecWhseShipmentLine."Source Line No.");
        RecReservationEntry.SETRANGE("Item No.", RecWhseShipmentLine."Item No.");
        IF RecReservationEntry.FINDSET THEN BEGIN
            REPEAT
                VJsonObjectReservas.Add('No', RecWhseShipmentLine."No.");
                VJsonObjectReservas.Add('LineNo', FormatoNumero(RecWhseShipmentLine."Line No."));
                VJsonObjectReservas.Add('EntryNo', RecReservationEntry."Entry No.");
                VJsonObjectReservas.Add('LotNo', RecReservationEntry."Lot No.");
                VJsonObjectReservas.Add('SerialNo', RecReservationEntry."Serial No.");
                VJsonObjectReservas.Add('PackageNo', RecReservationEntry."Package No.");

                VJsonObjectReservas.Add('Quantity', FormatoNumero(-RecReservationEntry."Quantity (Base)"));

                VJsonArrayReservas.Add(VJsonObjectReservas.Clone());
                Clear(VJsonObjectReservas);

            UNTIL RecReservationEntry.NEXT = 0;
        END;

        exit(VJsonArrayReservas);
    end;


    /*
        local procedure Sugerencias_Envios(RecWhseShipmentLine: Record "Warehouse Shipment Line"): JsonArray
        var
            QueryLotInventory: Query "Lot Numbers by Bin Exp";
            RecWarehouseSetup: Record "Warehouse Setup";
            RecReservationEntry: Record "Reservation Entry";
            VJsonObjectFEFO: JsonObject;
            VJsonArrayFEFO: JsonArray;

            Contador: Integer;

            CantidadEnReservas: Integer;
        begin

            RecWarehouseSetup.Get();
            if RecWarehouseSetup."Work Location" = '' THEN ERROR('No se ha definido el almacén de trabajo en la configuración');
            if RecWarehouseSetup."Work Bin" = '' THEN ERROR('No se ha definido la ubicación de trabajo en la configuración');

            VJsonObjectFEFO.Add('ItemNo', '');
            VJsonObjectFEFO.Add('LotNo', '');
            VJsonObjectFEFO.Add('Quantity', '');
            VJsonObjectFEFO.Add('ExpirationDate', '');

            Clear(QueryLotInventory);
            QueryLotInventory.SetFilter(QueryLotInventory.Item_No, '=%1', RecWhseShipmentLine."Item No.");
            QueryLotInventory.SetRange(QueryLotInventory.Location_Code, RecWarehouseSetup."Work Location");
            QueryLotInventory.SetRange(QueryLotInventory.Bin_Code, RecWarehouseSetup."Work Bin");
            QueryLotInventory.Open();
            Contador := 0;
            WHILE ((QueryLotInventory.READ) AND (Contador <= 5)) DO BEGIN

                //Buscar si ya está en reservas
                CantidadEnReservas := 0;
                Clear(RecReservationEntry);
                RecReservationEntry.SETRANGE("Item No.", RecWhseShipmentLine."Item No.");
                RecReservationEntry.SetRange("Source Type", 37);
                RecReservationEntry.SetRange("Source Subtype", 1);
                RecReservationEntry.SetRange("Lot No.", QueryLotInventory.Lot_No);
                IF RecReservationEntry.FindSet() then
                    repeat
                        CantidadEnReservas += (-RecReservationEntry.Quantity);
                    until RecReservationEntry.Next() = 0;

                if (QueryLotInventory.Sum_Qty_Base > CantidadEnReservas) then begin

                    VJsonObjectFEFO.Replace('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectFEFO.Replace('LotNo', QueryLotInventory.Lot_No);
                    VJsonObjectFEFO.Replace('Quantity', QuitarPunto(Format(QueryLotInventory.Sum_Qty_Base - CantidadEnReservas)));
                    VJsonObjectFEFO.Replace('ExpirationDate', Format(QueryLotInventory.Expiration_Date, 10, '<day,2>/<month,2>/<year4>'));

                    VJsonArrayFEFO.Add(VJsonObjectFEFO.Clone());

                    Contador += 1;

                end;
            end;

            exit(VJsonArrayFEFO);
        end;
    */

    procedure Asignar(xCantidad: Integer; xItemNo: Code[50]; xLocation: Code[50]; xLotNo: Code[50]; xSerialNo: Code[50]; xPackageNo: Code[50]; xOrder: Code[50]; xLine: Integer): Text
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackageNo: Record "Package No. Information";
        RecReservationEntry: Record "Reservation Entry";
        RecWarehouseSetup: Record "Warehouse Setup";
        JsonText: Text;
        NumLinea: Integer;

    begin
        RecWarehouseSetup.Get();
        //if RecWarehouseSetup."Work Location" = '' THEN ERROR('No se ha definido el almacén de trabajo en la configuración');
        //if RecWarehouseSetup."Work Bin" = '' THEN ERROR('No se ha definido la ubicación de trabajo en la configuración');


        Clear(RecReservationEntry);
        IF RecReservationEntry.FindLast() THEN
            NumLinea := RecReservationEntry."Entry No." + 1
        else
            NumLinea := 1;


        if (xCantidad > 0) then begin

            //Buscar si existe ese lote
            Clear(RecReservationEntry);
            RecReservationEntry.SetRange("Source Type", 37);
            RecReservationEntry.SetRange("Source Subtype", 1);
            RecReservationEntry.SetRange("Item No.", xItemNo);
            RecReservationEntry.SetRange(RecReservationEntry."Location Code", xLocation);
            RecReservationEntry.SetRange("Reservation Status", RecReservationEntry."Reservation Status"::Surplus);
            RecReservationEntry.SetRange("Source ID", xOrder); //1007
            RecReservationEntry.SetRange("Source Ref. No.", xLine); //10000
            IF (xLotNo <> '') then begin
                if not Existe_Lote(xLotNo, xItemNo) then Error(lblErrorLote);

                RecReservationEntry.SetRange("Lot No.", xLotNo);
            end;
            IF (xSerialNo <> '') then begin
                if not Existe_Serie(xSerialNo) then Error(lblErrorSerie);
                if Existe_Serie_En_Envio(xSerialNo) then Error(lblErrorSerialDuplicadoEnvio);

                RecReservationEntry.SetRange("Serial No.", xSerialNo);
            end;
            IF (xPackageNo <> '') then begin
                if not Existe_Paquete(xPackageNo) then Error(lblErrorPaquete);

                RecReservationEntry.SetRange("Package No.", xPackageNo);
            end;
            if RecReservationEntry.FindFirst() then begin
                RecReservationEntry.Validate(RecReservationEntry."Quantity (Base)", RecReservationEntry."Quantity (Base)" - xCantidad);
                RecReservationEntry.Validate(RecReservationEntry.Quantity, RecReservationEntry.Quantity - xCantidad);
                RecReservationEntry.MODIFY();
            end else begin


                RecReservationEntry.Init();
                RecReservationEntry."Entry No." := NumLinea;
                RecReservationEntry.Validate("Source Type", 37);
                RecReservationEntry.Validate("Source Subtype", 1);
                RecReservationEntry.Validate("Item No.", xItemNo);
                RecReservationEntry.Validate(RecReservationEntry."Location Code", xLocation);
                RecReservationEntry.Validate(RecReservationEntry."Quantity (Base)", -xCantidad);
                RecReservationEntry.Validate(RecReservationEntry.Quantity, -xCantidad);
                RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Surplus;
                RecReservationEntry.Validate("Source ID", xOrder); //1007
                RecReservationEntry.Validate("Source Ref. No.", xLine); //10000

                case TipoSeguimientoProducto(xItemNo) of
                    0://Sin Seguimiento
                        begin
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::None);
                        end;
                    1://Lote
                        begin
                            RecReservationEntry.Validate("Lot No.", xLotNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Lot No.");
                        end;
                    2://Serie
                        begin

                            RecReservationEntry.Validate("Serial No.", xSerialNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Serial No.");
                        end;
                    3://Lote y Serie
                        begin
                            RecReservationEntry.Validate("Lot No.", xLotNo);
                            RecReservationEntry.Validate("Serial No.", xSerialNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Lot and Serial No.");
                        end;
                    4://Lote y Paquete
                        begin
                            RecReservationEntry.Validate("Lot No.", xLotNo);
                            RecReservationEntry.Validate("Package No.", xPackageNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Lot and Package No.");
                        end;
                    5://Serie y Paquete
                        begin
                            RecReservationEntry.Validate("Serial No.", xSerialNo);
                            RecReservationEntry.Validate("Package No.", xPackageNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Serial and Package No.");
                        end;
                    6://Lote, Serie y Paquete
                        begin
                            RecReservationEntry.Validate("Lot No.", xLotNo);
                            RecReservationEntry.Validate("Serial No.", xSerialNo);
                            RecReservationEntry.Validate("Package No.", xPackageNo);
                            RecReservationEntry.Validate(RecReservationEntry."Item Tracking", RecReservationEntry."Item Tracking"::"Lot and Serial and Package No.");
                        end;
                end;

                RecReservationEntry.Insert();
            end;

        end;






    end;

    procedure Eliminar_De_Envio(xCantidad: Integer; xEntryNo: Integer): Text
    var
        RecLotNo: Record "Lot No. Information";
        RecReservationEntry: Record "Reservation Entry";
        RecWarehouseSetup: Record "Warehouse Setup";
        JsonText: Text;
        NumLinea: Integer;

    begin

        if (xCantidad > 0) then begin

            //Buscar si existe ese lote
            Clear(RecReservationEntry);
            RecReservationEntry.SetRange("Source Type", 37);
            RecReservationEntry.SetRange("Source Subtype", 1);
            RecReservationEntry.SetRange("Entry No.", xEntryNo);
            if RecReservationEntry.FindFirst() then begin
                RecReservationEntry.Validate(RecReservationEntry."Quantity (Base)", RecReservationEntry."Quantity (Base)" + xCantidad);
                RecReservationEntry.Validate(RecReservationEntry.Quantity, RecReservationEntry.Quantity + xCantidad);
                RecReservationEntry.MODIFY();
                if RecReservationEntry."Quantity (Base)" = 0 then RecReservationEntry.Delete();
            end;
        end;

    end;

    local procedure Existe_Serie_En_Envio(xSerialNo: Text): Boolean
    var
        RecReservationEntry: Record "Reservation Entry";
    begin
        Clear(RecReservationEntry);
        RecReservationEntry.SetRange("Source Type", 37);
        RecReservationEntry.SetRange("Source Subtype", 1);
        RecReservationEntry.SetRange("Serial No.", xSerialNo);
        if RecReservationEntry.FindFirst() then
            exit(true)
        else
            exit(false);
    end;

    procedure Registrar_Envio(xEnvio: Text; xLinea: Integer) Estado: Text
    var
        WhseShipmentHeader: record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        PostedWhseShipLine: record "Posted Whse. Shipment Line";
        WhsePostShipmentMgt: Codeunit "Whse.-Post Shipment";
        SalesShipmentLine: Record "Sales Shipment Line";
    begin

        WhseShipmentHeader.Reset;
        WhseShipmentHeader.SetRange("No.", xEnvio);
        IF NOT WhseShipmentHeader.Findfirst then error(lblErrorEnvio);

        WhseShipmentHeader."Posting Date" := WORKDATE;
        WhseShipmentHeader.Modify;

        //Actualizar_Cantidad_Enviar(xEnvio);
        WhseShipmentLine.RESET;
        WhseShipmentLine.SETRANGE("No.", xEnvio);
        if (xLinea > 0) then
            WhseShipmentLine.SETRANGE("Line No.", xLinea);

        IF WhseShipmentLine.FindFirst THEN BEGIN
            WhsePostShipmentMgt.RUN(WhseShipmentLine);
        END;

        /*IF Estado = 'True' then begin
            PostedWhseShipLine.Reset;
            PostedWhseShipLine.SetCurrentKey("Whse. Shipment No.", "Whse Shipment Line No.");
            PostedWhseShipLine.SetRange("Whse. Shipment No.", xEnvio);
            PostedWhseShipLine.SetRange("Source Document", PostedWhseShipLine."Source Document"::"Sales Order");
            PostedWhseShipLine.Setfilter("Source No.", '<>%1');
            IF PostedWhseShipLine.Findfirst then begin
                SalesShipmentLine.Reset();
                SalesShipmentLine.SetCurrentKey("Order No.", "Order Line No.", "Posting Date");
                SalesShipmentLine.SetRange("Order No.", PostedWhseShipLine."Source No.");
                SalesShipmentLine.SetRange("Order Line No.", PostedWhseShipLine."Source Line No.");
                IF SalesShipmentLine.Findfirst then begin
                    PrinterMgt.Impresion_Albaran(SalesShipmentLine."Document No.");
                end;
            end;
        end;*/
    end;


    #endregion

    #region INVENTARIO


    procedure Inventario_Trazabilidad(xLocation: Text; xTrackNo: Text; xItemNo: Text): Text
    var

        lTipo: Code[1];

        RecWarehouseSetup: record "Warehouse Setup";
        QueryLotInventory: Query "Lot Numbers by Bin";
        RecItem: Record Item;

        VJsonObjectTrazabilidad: JsonObject;

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        Cantidad: Decimal;
        Iventario: Decimal;
        VJsonText: Text;

        Encontrado: Boolean;

        Primero: Boolean;
        vPaquete: Text;
        vSerie: Text;

        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        iTipoTrack: Integer;
    begin

        RecWarehouseSetup.Get();

        lTipo := Tipo_Trazabilidad(xTrackNo);

        if (lTipo = 'N') THEN ERROR(lblErrorTrackNo + ' (' + xTrackNo + ')');

        VJsonObjectTrazabilidad.Add('TrackNo', xTrackNo);

        Clear(QueryLotInventory);
        case lTipo of
            'L':
                begin
                    QueryLotInventory.SetRange(QueryLotInventory.Lot_No, xTrackNo);
                end;
            'S':
                begin
                    QueryLotInventory.SetRange(QueryLotInventory.Serial_No, xTrackNo);
                end;
            'P':
                begin
                    QueryLotInventory.SetRange(QueryLotInventory.Package_No, xTrackNo);
                end;
            'I':
                begin
                    QueryLotInventory.SetRange(QueryLotInventory.Item_No, xTrackNo);
                end;
            else
        end;

        if (xItemNo <> '') then
            QueryLotInventory.SetRange(QueryLotInventory.Item_No, xItemNo);

        //QueryLotInventory.Open();
        //Inventario por ubicación

        QueryLotInventory.SetFilter(QueryLotInventory.Location_Code, xLocation);

        Primero := true;
        Cantidad := 0;
        QueryLotInventory.Open();
        WHILE QueryLotInventory.READ DO BEGIN
            if (Primero) then begin
                VJsonObjectTrazabilidad.Add('Tipo', lTipo);
                VJsonObjectTrazabilidad.Add('TipoDesc', Desc_Tipo(lTipo));

                IF ((lTipo = 'P') OR (lTipo = 'L')) THEN begin

                    VJsonObjectTrazabilidad.Add('ItemNo', '');
                    VJsonObjectTrazabilidad.Add('Description', '');
                end;
                IF ((lTipo = 'S') OR (lTipo = 'I')) THEN begin
                    VJsonObjectTrazabilidad.Add('ItemNo', QueryLotInventory.Item_No);
                    VJsonObjectTrazabilidad.Add('Description', Descripcion_ItemNo(QueryLotInventory.Item_No));
                end;
                Primero := false;
            end;

            VJsonObjectInventario.Add('ItemNo', QueryLotInventory.Item_No);
            VJsonObjectInventario.Add('Description', Descripcion_ItemNo(QueryLotInventory.Item_No));

            iTipoTrack := TipoSeguimientoProducto(QueryLotInventory.Item_No);
            VJsonObjectInventario.Add('TipoSeguimiento', Format(iTipoTrack));

            /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
            case iTipoTrack of
                0:
                    begin
                        VJsonObjectInventario.Add('TrackNo', '');
                        VJsonObjectInventario.Add('TipoTrack', 'I');
                    end;
                2, 3, 5, 6:
                    begin
                        VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Serial_No);
                        VJsonObjectInventario.Add('TipoTrack', 'S');
                    end;
                1, 4:
                    begin
                        VJsonObjectInventario.Add('TrackNo', QueryLotInventory.Lot_No);
                        VJsonObjectInventario.Add('TipoTrack', 'L');
                    end;

            end;

            VJsonObjectInventario.Add('LotNo', QueryLotInventory.Lot_No);
            VJsonObjectInventario.Add('SerialNo', QueryLotInventory.Serial_No);
            VJsonObjectInventario.Add('PackageNo', QueryLotInventory.Package_No);

            if ((RecWarehouseSetup."Codigo Sin Paquete" <> '') AND (RecWarehouseSetup."Codigo Sin Paquete" <> QueryLotInventory.Package_No)) then
                VJsonObjectInventario.Add('InPackage', FormatoBoolean(True))
            else
                VJsonObjectInventario.Add('InPackage', FormatoBoolean(False));

            VJsonObjectInventario.Add('Zone', QueryLotInventory.Zone_Code);
            VJsonObjectInventario.Add('Bin', QueryLotInventory.Bin_Code);
            VJsonObjectInventario.Add('BinInventory', FormatoNumero(QueryLotInventory.Sum_Qty_Base));

            VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
            Clear(VJsonObjectInventario);

        END;

        VJsonObjectTrazabilidad.Add('Bins', VJsonArrayInventario.Clone());

        QueryLotInventory.Close();

        VJsonObjectTrazabilidad.WriteTo(VJsonText);
        exit(VJsonText);

    end;


    local procedure Desc_Tipo(xTipo: Text): Text
    var

    begin
        case xTipo of
            'I':
                exit(lblReferencia);
            'L':
                exit(lblLote);
            'S':
                exit(lblSerie);
            'P':
                exit(lblPaquete);
            else
                exit('');
        end;
    end;


    procedure Inventario_Recurso(xResourceNo: Text; xLocation: Text; xZone: Text; xBin: Text; xItemNo: Text): Text
    var

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        //RecWarehouseJournalLine: Record "Warehouse Journal Line";
        //RecWarehouseSetup: Record "Warehouse Setup";
        RecDiario: RecordRef;
        RecLocation: Record Location;
        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;
    begin

        if (xResourceNo = '') then ERROR(lblErrorRecurso);

        //RecWarehouseSetup.get();
        RecLocation.Get(xLocation);

        if ((RecLocation.AppInvJournalTemplateName = '') or (RecLocation.AppInvJournalBatchName = '')) then
            ERROR(lblErrorDiarioInv);

        Clear(RecRecurso);
        RecRecurso.SetRange("No.", xResourceNo);
        if not RecRecurso.FindFirst() THEN ERROR(lblErrorRecurso);

        if (RecLocation."Almacen Avanzado") then
            VJsonText := Inventario_Recurso_Almacen_Avanzado(xResourceNo, xLocation, xZone, xBin, xItemNo)
        else
            Error(lblErrorSinInventario);

        exit(VJsonText);

    end;



    procedure Inventario_Recurso_Almacen_Avanzado(xResourceNo: Text; xLocation: Text; xZone: Text; xBin: Text; xItemNo: Text): Text
    var

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        RecWarehouseJournalLine: Record "Warehouse Journal Line";

        RecLocation: Record Location;
        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        iTipoTrack: Integer;
    begin

        if (xResourceNo = '') then ERROR(lblErrorRecurso);

        //RecWarehouseSetup.get();
        RecLocation.Get(xLocation);

        //Todo lo que no sea urgencia
        Clear(RecWarehouseJournalLine);
        RecWarehouseJournalLine.SetRange("Location Code", xLocation);
        RecWarehouseJournalLine.SetRange("Journal Template Name", RecLocation.AppInvJournalTemplateName);
        RecWarehouseJournalLine.SetRange("Journal Batch Name", RecLocation.AppInvJournalBatchName);

        if (xZone <> '') then
            RecWarehouseJournalLine.SetRange("Zone Code", xZone);
        if (xBin <> '') then
            RecWarehouseJournalLine.SetRange("Bin Code", xBin);
        if (xItemNo <> '') then
            RecWarehouseJournalLine.SetRange("Item No.", xItemNo);

        if RecWarehouseJournalLine.findset then begin
            repeat
                VJsonObjectInventario.Add('Location', RecWarehouseJournalLine."Location Code");
                VJsonObjectInventario.Add('LineNo', FormatoNumero(RecWarehouseJournalLine."Line No."));
                VJsonObjectInventario.Add('ItemNo', RecWarehouseJournalLine."Item No.");
                VJsonObjectInventario.Add('Description', RecWarehouseJournalLine.Description);
                VJsonObjectInventario.Add('TipoSeguimimento', Format(TipoSeguimientoProducto(RecWarehouseJournalLine."Item No.")));
                VJsonObjectInventario.Add('Zone', RecWarehouseJournalLine."Zone Code");
                VJsonObjectInventario.Add('Bin', RecWarehouseJournalLine."Bin Code");
                VJsonObjectInventario.Add('LotNo', RecWarehouseJournalLine."Lot No.");
                VJsonObjectInventario.Add('SerialNo', RecWarehouseJournalLine."Serial No.");
                VJsonObjectInventario.Add('PackagelNo', RecWarehouseJournalLine."Package No.");

                iTipoTrack := TipoSeguimientoProducto(RecWarehouseJournalLine."Item No.");

                case iTipoTrack of
                    0:
                        begin
                            VJsonObjectInventario.Add('TrackNo', '');
                            VJsonObjectInventario.Add('TipoTrack', 'I');
                        end;
                    2, 3, 5, 6:
                        begin
                            VJsonObjectInventario.Add('TrackNo', RecWarehouseJournalLine."Serial No.");
                            VJsonObjectInventario.Add('TipoTrack', 'S');
                        end;
                    1, 4:
                        begin
                            VJsonObjectInventario.Add('TrackNo', RecWarehouseJournalLine."Lot No.");
                            VJsonObjectInventario.Add('TipoTrack', 'L');
                        end;

                end;

                VJsonObjectInventario.Add('Date', FormatoFecha(RecWarehouseJournalLine."Registering Date"));
                VJsonObjectInventario.Add('Calculada', FormatoNumero(RecWarehouseJournalLine."Qty. (Calculated)"));
                VJsonObjectInventario.Add('Real', FormatoNumero(RecWarehouseJournalLine."Qty. (Phys. Inventory)"));
                VJsonObjectInventario.Add('Diferencia', FormatoNumero(RecWarehouseJournalLine.Quantity));
                VJsonObjectInventario.Add('Unit', RecWarehouseJournalLine."Unit of Measure Code");

                VJsonObjectInventario.Add('Leido', FormatoBoolean(RecWarehouseJournalLine.Leido));

                VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
                Clear(VJsonObjectInventario);

            until RecWarehouseJournalLine.Next() = 0;

        end;

        VJsonArrayInventario.WriteTo(VJsonText);
        exit(VJsonText);

    end;





    procedure Validar_Linea_Inventario_Almacen_Avanzado(xTrackNo: Text; xBin: Text; xQuantity: Decimal; xItemNo: Text; xLocation: Text): Text
    var

        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecBin: Record Bin;
        RecLocation: Record Location;

        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        NumeroLinea: Integer;
        sTipo: Code[1];
    begin

        sTipo := Tipo_Dato(xTrackNo);

        CLEAR(RecWarehouseJournalLine);

        case sTipo of
            'L':
                RecWarehouseJournalLine.SetRange("Lot No.", xTrackNo);
            'S':
                RecWarehouseJournalLine.SetRange("Serial No.", xTrackNo);
            'P':
                RecWarehouseJournalLine.SetRange("Package No.", xTrackNo);
            'N':
                begin
                    IF (TipoSeguimientoProducto(xItemNo) > 0) THEN
                        ERROR(lblErrorTrackNo);
                    RecWarehouseJournalLine.SetRange("Item No.", xItemNo);
                end;

        end;

        RecWarehouseJournalLine.SetRange("Bin Code", xBin);

        IF (RecWarehouseJournalLine.FindFirst()) THEN begin

            RecWarehouseJournalLine.Validate("Qty. (Phys. Inventory)", xQuantity);
            RecWarehouseJournalLine.Leido := true;
            RecWarehouseJournalLine.Modify();
        end else begin

            Agregar_Linea_Inventario_Almacen_Avanzado(xTrackNo, xBin, xQuantity, sTipo, xItemNo, xLocation);

        end;

    end;


    procedure Agregar_Linea_Inventario_Almacen_Avanzado(xTrackNo: Text; xBin: Text; xQuantity: Decimal; xTipo: Code[1]; xItemNo: Text; xLocation: Text): Text
    var

        RecWarehouseJournalLine: Record "Warehouse Journal Line";
        RecWarehouseJournalLineAux: Record "Warehouse Journal Line";
        RecBin: Record Bin;
        RecLocation: Record Location;

        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        NumeroLinea: Integer;
    begin


        RecLocation.GET(xLocation);
        IF (RecLocation.AppInvJournalTemplateName = '') THEN ERROR(lblErrorDiarioInv);
        IF (RecLocation.AppInvJournalBatchName = '') THEN ERROR(lblErrorDiarioInv);

        clear(RecWarehouseJournalLineAux);
        RecWarehouseJournalLineAux.SETRANGE("Journal Template Name", RecLocation.AppInvJournalTemplateName);
        RecWarehouseJournalLineAux.SETRANGE("Journal Batch Name", RecLocation.AppInvJournalBatchName);
        if RecWarehouseJournalLineAux.FindLast() then
            NumeroLinea := RecWarehouseJournalLineAux."Line No." + 1001
        else
            Error(lblErrorSinInventario);
        ;

        //Se añade la línea nueva
        Clear(RecBin);
        RecBin.SetRange(code, xBin);
        IF NOT RecBin.FindFirst() then Error(StrSubstNo(lblErrorUbicacion, xBin));

        RecWarehouseJournalLine.Init();
        RecWarehouseJournalLine."Journal Template Name" := RecLocation.AppInvJournalTemplateName;
        RecWarehouseJournalLine."Journal Batch Name" := RecLocation.AppInvJournalBatchName;
        NumeroLinea += 1000;
        RecWarehouseJournalLine."Line No." := NumeroLinea;
        RecWarehouseJournalLine."Registering Date" := Today;
        RecWarehouseJournalLine."Location Code" := RecBin."Location Code";
        RecWarehouseJournalLine."Zone Code" := RecBin."Zone Code";
        RecWarehouseJournalLine.Validate("Bin Code", xBin);
        RecWarehouseJournalLine.Validate("Item No.", xItemNo);

        if (xTipo = '') then xTipo := Tipo_Dato(xTrackNo);

        case xTipo of
            'L':
                RecWarehouseJournalLine."Lot No." := xTrackNo;
            'S':
                RecWarehouseJournalLine."Serial No." := xTrackNo;
            'P':
                RecWarehouseJournalLine."Package No." := xTrackNo;
        //'N':
        //    Error(lblErrorTrackNo);
        end;

        RecWarehouseJournalLine."To Zone Code" := RecBin."Zone Code";
        RecWarehouseJournalLine."To Bin Code" := RecBin.Code;

        Clear(RecLocation);
        RecLocation.Get(RecBin."Location Code");
        Clear(RecBin);
        RecBin.SetRange(code, RecLocation."Adjustment Bin Code");
        IF NOT RecBin.FindFirst() then Error(StrSubstNo(lblErrorUbicacion, RecLocation."Adjustment Bin Code"));

        RecWarehouseJournalLine."From Zone Code" := RecBin."Zone Code";
        RecWarehouseJournalLine."From Bin Code" := RecBin.Code;
        RecWarehouseJournalLine."Source Code" := RecWarehouseJournalLineAux."Source Code"; //'INVFISALM';
        RecWarehouseJournalLine."Phys. Inventory" := true;
        RecWarehouseJournalLine."From Bin Type Code" := RecBin."Bin Type Code";
        RecWarehouseJournalLine."Whse. Document No." := RecWarehouseJournalLineAux."Whse. Document No.";
        RecWarehouseJournalLine."Whse. Document Type" := RecWarehouseJournalLine."Whse. Document Type"::"Whse. Phys. Inventory";
        RecWarehouseJournalLine.Validate("Qty. (Calculated)", 0);
        RecWarehouseJournalLine.Validate("Qty. (Calculated) (Base)", 0);
        RecWarehouseJournalLine.Validate("Qty. (Phys. Inventory)", xQuantity);
        RecWarehouseJournalLine.Validate("Qty. (Phys. Inventory) (Base)", xQuantity);
        RecWarehouseJournalLine."Qty. per Unit of Measure" := 1;
        RecWarehouseJournalLine."Entry Type" := RecWarehouseJournalLine."Entry Type"::"Positive Adjmt.";

        RecWarehouseJournalLine.Leido := true;

        RecWarehouseJournalLine.Insert();

    end;





    #endregion

    #region REGISTRO PEDIDOS INVENTARIO


    local procedure Objeto_Registro_Inventario(xOrderNo: code[20]; xRecordingNo: Integer): JsonObject
    var

        RecPhysInvtHeader: Record "Phys. Invt. Record Header";
        RecPhysInvtLine: Record "Phys. Invt. Record Line";

        RecItemReference: Record "Item Reference";
        RecWarehouseSetup: Record "Warehouse Setup";
        RecItem: Record Item;
        Comentarios: Text;

        //RecItem: Record Item;
        VJsonObjectInventory: JsonObject;
        VJsonArrayInventory: JsonArray;
        VJsonObjectLines: JsonObject;
        VJsonArrayLines: JsonArray;

        VJsonText: Text;

        CR: Char;
    begin

        CR := 13;

        RecWarehouseSetup.Get();

        clear(RecPhysInvtHeader);
        RecPhysInvtHeader.SetRange("Order No.", xOrderNo);
        RecPhysInvtHeader.SetRange("Recording No.", xRecordingNo);
        if RecPhysInvtHeader.FindFirst() then;

        VJsonObjectInventory.Add('OrderNo', RecPhysInvtHeader."Order No.");
        VJsonObjectInventory.Add('RecordingNo', FormatoNumero(RecPhysInvtHeader."Recording No."));
        VJsonObjectInventory.Add('Location', RecPhysInvtHeader."Location Code");
        VJsonObjectInventory.Add('Date', FormatoFecha(RecPhysInvtHeader."Date Recorded"));
        VJsonObjectInventory.Add('Description', RecPhysInvtHeader.Description);
        VJsonObjectInventory.Add('Status', FORMAT(RecPhysInvtHeader.Status));

        Clear(RecPhysInvtLine);
        RecPhysInvtLine.SetRange("Order No.", RecPhysInvtHeader."Order No.");
        RecPhysInvtLine.SetRange("Recording No.", RecPhysInvtHeader."Recording No.");
        RecPhysInvtLine.SetRange(Recorded, true);
        if RecPhysInvtLine.FindFirst() then
            VJsonObjectInventory.Add('Partially', FormatoBoolean(true))
        else
            VJsonObjectInventory.Add('Partially', FormatoBoolean(false));

        exit(VJsonObjectInventory);

    end;

    procedure Lineas_Registro_Inventario_Recurso(xResourceNo: Text; xLocation: Text; xOrderNo: Text; xRecordingNo: Integer): Text
    var

        VJsonObjectInventario: JsonObject;
        VJsonArrayInventario: JsonArray;

        RecPhyInvetRecordLine: Record "Phys. Invt. Record Line";

        RecLocation: Record Location;
        RecRecurso: Record Resource;
        vJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        iTipoTrack: Integer;
    begin

        RecRecurso.Get(xResourceNo);
        //RecWarehouseSetup.get();
        RecLocation.Get(xLocation);

        //Todo lo que no sea urgencia
        Clear(RecPhyInvetRecordLine);
        RecPhyInvetRecordLine.SetRange("Order No.", xOrderNo);
        RecPhyInvetRecordLine.SetRange("Recording No.", xRecordingNo);
        if RecPhyInvetRecordLine.findset then begin
            repeat
                VJsonObjectInventario.Add('OrderNo', RecPhyInvetRecordLine."Order No.");
                VJsonObjectInventario.Add('RecordingNo', RecPhyInvetRecordLine."Recording No.");
                VJsonObjectInventario.Add('LineNo', FormatoNumero(RecPhyInvetRecordLine."Line No."));

                VJsonObjectInventario.Add('Location', RecPhyInvetRecordLine."Location Code");
                VJsonObjectInventario.Add('ItemNo', RecPhyInvetRecordLine."Item No.");
                VJsonObjectInventario.Add('Description', RecPhyInvetRecordLine.Description);
                VJsonObjectInventario.Add('TipoSeguimimento', Format(TipoSeguimientoProducto(RecPhyInvetRecordLine."Item No.")));
                VJsonObjectInventario.Add('Zone', '');
                VJsonObjectInventario.Add('Bin', RecPhyInvetRecordLine."Bin Code");
                VJsonObjectInventario.Add('LotNo', RecPhyInvetRecordLine."Lot No.");
                VJsonObjectInventario.Add('SerialNo', RecPhyInvetRecordLine."Serial No.");
                VJsonObjectInventario.Add('PackagelNo', '');

                iTipoTrack := TipoSeguimientoProducto(RecPhyInvetRecordLine."Item No.");

                case iTipoTrack of
                    0:
                        begin
                            VJsonObjectInventario.Add('TrackNo', '');
                            VJsonObjectInventario.Add('TipoTrack', 'I');
                        end;
                    2, 3, 5, 6:
                        begin
                            VJsonObjectInventario.Add('TrackNo', RecPhyInvetRecordLine."Serial No.");
                            VJsonObjectInventario.Add('TipoTrack', 'S');
                        end;
                    1, 4:
                        begin
                            VJsonObjectInventario.Add('TrackNo', RecPhyInvetRecordLine."Lot No.");
                            VJsonObjectInventario.Add('TipoTrack', 'L');
                        end;

                end;

                VJsonObjectInventario.Add('Date', FormatoFecha(RecPhyInvetRecordLine."Date Recorded"));

                if RecRecurso."Ver cantidad inventario" then begin
                    VJsonObjectInventario.Add('Calculada', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                    VJsonObjectInventario.Add('Real', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                    VJsonObjectInventario.Add('Diferencia', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                end else begin
                    if (RecPhyInvetRecordLine.Recorded) then begin
                        VJsonObjectInventario.Add('Calculada', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                        VJsonObjectInventario.Add('Real', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                        VJsonObjectInventario.Add('Diferencia', FormatoNumero(RecPhyInvetRecordLine.Quantity));
                    end else begin
                        VJsonObjectInventario.Add('Calculada', FormatoNumero(0));
                        VJsonObjectInventario.Add('Real', FormatoNumero(0));
                        VJsonObjectInventario.Add('Diferencia', FormatoNumero(0));
                    end;

                end;


                VJsonObjectInventario.Add('Unit', RecPhyInvetRecordLine."Unit of Measure Code");

                VJsonObjectInventario.Add('Leido', FormatoBoolean(RecPhyInvetRecordLine.Recorded));

                VJsonArrayInventario.Add(VJsonObjectInventario.Clone());
                Clear(VJsonObjectInventario);

            until RecPhyInvetRecordLine.Next() = 0;

        end;

        VJsonArrayInventario.WriteTo(vJsonText);
        exit(vJsonText);

    end;

    procedure Agregar_Linea_Registro_Inventario(xTrackType: Text; xTrackNo: Text; xBin: Text; xQuantity: Decimal; xItemNo: Text; xLocation: Text; xOrderNo: Text; xRecordingNo: Integer)
    var


        RecPhyInvetRecordLine: Record "Phys. Invt. Record Line";
        RecPhyInvetRecordLineAux: Record "Phys. Invt. Record Line";

        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";

        RecLocation: Record Location;

        RecRecurso: Record Resource;
        VJsonText: Text;

        lContenedor: Text;
        lSoloEnAlmacen: Integer;
        bSoloEnAlmacen: Boolean;

        NumeroLinea: Integer;
    begin

        RecLocation.GET(xLocation);

        Clear(RecPhyInvetRecordLine);
        RecPhyInvetRecordLine.SetRange("Order No.", xOrderNo);
        RecPhyInvetRecordLine.SetRange("Recording No.", xRecordingNo);
        RecPhyInvetRecordLine.SetRange("Item No.", xItemNo);

        if (xBin <> '') then
            RecPhyInvetRecordLine.SetRange("Bin Code", xBin);

        case xTrackType of
            'L':
                RecPhyInvetRecordLine.SetRange("Lot No.", xTrackNo);
            'S':
                RecPhyInvetRecordLine.SetRange("Serial No.", xTrackNo);
        end;

        if RecPhyInvetRecordLine.FindFirst() then begin
            IF (RecLocation.SumarCantidad) then begin
                if (RecPhyInvetRecordLine.Recorded) then
                    RecPhyInvetRecordLine.Quantity += xQuantity
                else
                    RecPhyInvetRecordLine.Quantity := xQuantity;
            end else
                RecPhyInvetRecordLine.Quantity := xQuantity;
            RecPhyInvetRecordLine.Recorded := true;
            RecPhyInvetRecordLine.Modify();
        end else begin

            NumeroLinea := 5000;
            clear(RecPhyInvetRecordLineAux);
            RecPhyInvetRecordLineAux.SetRange("Order No.", xOrderNo);
            RecPhyInvetRecordLineAux.SetRange("Recording No.", xRecordingNo);
            if RecPhyInvetRecordLineAux.FindLast() then
                NumeroLinea := RecPhyInvetRecordLineAux."Line No." + 10000;

            RecPhyInvetRecordLine.Init();
            RecPhyInvetRecordLine.Validate("Order No.", xOrderNo);
            RecPhyInvetRecordLine.Validate("Recording No.", xRecordingNo);
            RecPhyInvetRecordLine.Validate("Line No.", NumeroLinea);
            RecPhyInvetRecordLine.Validate("Item No.", xItemNo);

            if (xBin <> '') then
                RecPhyInvetRecordLine.Validate("Bin Code", xBin);

            case xTrackType of
                'L':
                    begin
                        Clear(RecLotNo);
                        RecLotNo.SetRange("Lot No.", xTrackNo);
                        RecLotNo.SetRange("Item No.", xItemNo);
                        if not RecLotNo.FindFirst() then Error(StrSubstNo(lblErrorLoteInternoNoExiste, xTrackNo));
                        RecPhyInvetRecordLine.Validate("Lot No.", xTrackNo);
                    end;

                'S':
                    begin
                        Clear(RecSerialNo);
                        RecSerialNo.SetRange("Serial No.", xTrackNo);
                        RecSerialNo.SetRange("Item No.", xItemNo);
                        if not RecSerialNo.FindFirst() then Error(StrSubstNo(lblErrorSerieInternoNoExiste, xTrackNo));
                        RecPhyInvetRecordLine.Validate("Serial No.", xTrackNo);
                    end;
            end;

            RecPhyInvetRecordLine.Validate(Quantity, xQuantity);
            RecPhyInvetRecordLine."Recorded Without Order" := true;
            RecPhyInvetRecordLine.Recorded := true;

            RecPhyInvetRecordLine.Insert();

        end;

    end;

    #endregion

    #region FUNCIONES BC




    /// <summary>
    /// Determina si es un Lote(L), Un Serie(S),Paquete(P), Nulo(N), Item(I)
    /// </summary>
    local procedure Tipo_Dato(xTrackNo: Text): Code[1]
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
        RecItem: Record Item;
    begin

        Clear(RecSerialNo);
        RecSerialNo.SetRange("Serial No.", xTrackNo);
        if RecSerialNo.FindFirst() then exit('S');

        Clear(RecLotNo);
        RecLotNo.SetRange("Lot No.", xTrackNo);
        if RecLotNo.FindFirst() then exit('L');

        Clear(RecPackage);
        RecPackage.SetRange("Package No.", xTrackNo);
        if RecPackage.FindFirst() then exit('P');

        Clear(RecItem);
        RecItem.SetRange("No.", xTrackNo);
        if RecItem.FindFirst() then exit('I');

        exit('N');
    end;


    local procedure Item_Tipo_Dato(xTrackNo: Text): Code[50]
    var
        RecLotNo: Record "Lot No. Information";
        RecSerialNo: Record "Serial No. Information";
        RecPackage: Record "Package No. Information";
    begin

        Clear(RecSerialNo);
        RecSerialNo.SetRange("Serial No.", xTrackNo);
        if RecSerialNo.FindFirst() then exit(RecSerialNo."Item No.");

        Clear(RecLotNo);
        RecLotNo.SetRange("Lot No.", xTrackNo);
        if RecLotNo.FindFirst() then exit(RecLotNo."Item No.");

        Clear(RecPackage);
        RecPackage.SetRange("Package No.", xTrackNo);
        if RecPackage.FindFirst() then exit(RecLotNo."Item No.");

        exit('');
    end;


    local procedure Existe_Referencia(xItemNo: Text; xAnalizarSeg: Boolean): Boolean
    var
        RecItem: Record Item;
    begin
        Clear(RecItem);
        RecItem.SetRange("No.", xItemNo);
        if not RecItem.FindFirst() then begin
            Error(StrSubstNo(lblErrorReferencia, xItemNo));
        end;

        if (xAnalizarSeg) then begin
            //Comprobar que tenga cod. seguimiento producto
            if RecItem."Item Tracking Code" = '' THEN Error(StrSubstNo(lblErrorCodSeguimiento, xItemNo));
        end;

    end;


    local procedure Existe_Lote(xLotNo: Text; xItemNo: Text): Boolean
    var
        RecLotNo: Record "Lot No. Information";
    begin
        Clear(RecLotNo);
        RecLotNo.SetRange("Lot No.", xLotNo);
        if not RecLotNo.FindFirst() then
            exit(false)
        else
            exit(true);
    end;

    local procedure Existe_Serie(xSerialNo: Text): Boolean
    var
        RecSerialNo: Record "Serial No. Information";
    begin
        Clear(RecSerialNo);
        RecSerialNo.SetRange("Serial No.", xSerialNo);
        if not RecSerialNo.FindFirst() then
            exit(false)
        else
            exit(true);
    end;

    local procedure Existe_Paquete(xPackageNo: Text): Boolean
    var
        RecPackageNo: Record "Package No. Information";
    begin
        Clear(RecPackageNo);
        RecPackageNo.SetRange("Package No.", xPackageNo);
        if not RecPackageNo.FindFirst() then
            exit(false)
        else
            exit(true);
    end;

    local procedure Ubicacion_Paquete(xPackageNo: Text; xLocation: Text): Text
    var
        QueryLotInventory: Query "Lot Numbers by Bin";
    begin

        Clear(QueryLotInventory);
        QueryLotInventory.SetFilter(QueryLotInventory.Location_Code, xLocation);
        QueryLotInventory.SetFilter(QueryLotInventory.Package_No, xPackageNo);

        QueryLotInventory.Open();
        if QueryLotInventory.READ then
            exit(QueryLotInventory.Bin_Code)
        else
            exit('');


    end;



    /// <summary>
    /// Busca Referencia Cruzada
    /// </summary>
    /// <param name="xItem">Referencia</param>
    /// <param name="xVendor">Provedor</param>
    local procedure Buscar_Referencia_Cruzada(xItem: Code[50]; xVendor: Code[50]): Code[50]
    var
        RecItemReference: Record "Item Reference";
    begin
        clear(RecItemReference);
        RecItemReference.SetRange("Reference No.", xItem);
        if (xVendor <> '') then begin
            RecItemReference.SetRange("Reference Type", RecItemReference."Reference Type"::Vendor);
            RecItemReference.SetRange("Reference Type No.", xVendor);
        END ELSE
            RecItemReference.SetRange("Reference Type", RecItemReference."Reference Type"::"Bar Code");

        IF RecItemReference.FindFirst() then
            exit(RecItemReference."Item No.")
        ELSE
            exit('');
    end;

    procedure Descripcion_ItemNo(xItem: Code[50]): Text
    var
        RecItem: Record Item;
    begin
        Clear(RecItem);
        RecItem.SetRange("No.", xItem);
        if RecItem.FindFirst() then
            Exit(RecItem.Description)
        else
            Exit('');
    end;

    ///<summary>1: Materia Prima - 2: Semielaborado - 3: Producto Terminado</summary>    
    procedure Base_Numero_Contenedor(xTipo: Integer; xItemNo: Text): Text
    var
        RecWarehouseSetup: Record "Warehouse Setup";
        RecLotNoInf: Record "Lot No. Information";
        RecItem: Record Item;
        cuNoSeriesManagement: Codeunit NoSeriesManagement;
        TxtContenedor: Text;
        xInicial: Text;
        Formato: Text;
        xNumero: Integer;
        sufijo: Text;
        SufijoNumSerie: Text;
    begin

        RecWarehouseSetup.get();

        TxtContenedor := '';

        /*if NOT RecWarehouseSetup."Usar serie para Lote" THEN BEGIN

            case xTipo of
                1:
                    begin
                        xInicial := RecWarehouseSetup."Prefijo Materia Prima";
                    end;
                2:
                    begin
                        xInicial := RecWarehouseSetup."Prefijo Semielaborado";
                    end;
                3:
                    begin
                        xInicial := RecWarehouseSetup."Prefijo Producto Terminado";
                    end;
            end;

            if (xInicial = '') then Error(lblErrorPrefijoLote);

            if (RecWarehouseSetup."Lot No Serial" = '') then Error(lblErrorNSerieLote);

            Formato := '<year,2><month,2><day,2><Hours24,2>';
            sufijo := cuNoSeriesManagement.GetNextNo(RecWarehouseSetup."Lot No Serial", WorkDate, true);
            TxtContenedor := xInicial + Format(CurrentDateTime, 8, Formato) + sufijo;
        END ELSE begin*/

        if (xItemNo = '') then error(lblErrorSinReferencia);
        RecItem.Get(xItemNo);
        if (RecItem."Lot No Serial" = '') then error(lblErrorNSerieLote);

        TxtContenedor := cuNoSeriesManagement.GetNextNo(RecItem."Lot No Serial", WorkDate, true);
        /*end;*/


        Clear(RecLotNoInf);
        RecLotNoInf.SetRange("Lot No.", TxtContenedor);
        if RecLotNoInf.FindFirst() then ERROR(lblErrorLoteInterno);


        exit(TxtContenedor);
    end;


    [TryFunction]
    local procedure App_Location(VAR xLocation: Text)
    var
        RecWarehouseSetup: Record "Warehouse Setup";
    begin
        RecWarehouseSetup.GET();
        if (RecWarehouseSetup."App Location" = '') then
            Error(lblErrorAlmacen)
        else
            xLocation := RecWarehouseSetup."App Location";


    end;

    /// <summary>
    /// AnalizarSeguimientoProducto.
    /// </summary>
    /// <param name="pItemNo">code[20].</param>
    /// <returns>Return 1:Lote 2:Serie 3:Lote y Serie 4:Lote y paquete 5: Serie y paquete 6: Lote, serie y paquete, 0: Sin seguimiento</returns>
    procedure TipoSeguimientoProducto(pItemNo: code[20]) rResultado: Integer;
    var
        EnumTracking: Enum "Item Tracking Entry Type";
    begin
        EnumTracking := AnalizarSeguimientoProducto(pItemNo);

        Case EnumTracking of
            EnumTracking::"Lot No.":
                rResultado := 1; //Lote
            EnumTracking::"Serial No.":
                rResultado := 2; //Serie
            EnumTracking::"Lot and Serial No.":
                rResultado := 3; //Lote y serie
            EnumTracking::"Lot and Package No.":
                rResultado := 4; //Lote y paquete
            EnumTracking::"Serial and Package No.":
                rResultado := 5; //Serie y paquete
            EnumTracking::"Lot and Serial and Package No.":
                rResultado := 6; //Lote, serie y paquete
            else
                rResultado := 0; //nada
        End

    end;

    procedure AnalizarSeguimientoProducto(pItemNo: code[20]) rResultado: Enum "Item Tracking Entry Type";
    var
        tItem: Record Item;
        tItemTrackingCode: Record "Item Tracking Code";
        SiLote: Boolean;
        SiSerie: Boolean;
        SiPack: Boolean;
        lblErrorItem: Label 'The item %1 does not exist', comment = 'ESP="El producto %1 no existe"';
    begin

        rResultado := rResultado::None;
        //Primero recuperamos y comprobaremos que el producto existe
        IF NOT tItem.GET(pItemNo) THEN
            ERROR(StrSubstNo(lblErrorItem, pItemNo));

        //Recuperamos el seguimiento del producto
        Silote := FALSE;
        SIserie := FALSE;
        SiPack := FALSE;
        IF tItem."Item Tracking Code" <> '' THEN BEGIN
            IF tItemTrackingCode.GET(tItem."Item Tracking Code") THEN BEGIN
                Silote := tItemTrackingCode."Lot Warehouse Tracking";
                Siserie := tItemTrackingCode."SN Warehouse Tracking";
                SiPack := tItemTrackingCode."Package Warehouse Tracking";
            END;

            IF (NOT SiLote) AND (NOT SiSerie) AND (NOT SiPack) THEN
                rResultado := rResultado::None
            ELSE
                IF SiLote AND SiSerie AND SiPack THEN
                    rResultado := rResultado::"Lot and Serial and Package No."
                ELSE
                    IF SiLote AND SiSerie AND (NOT SiPack) THEN
                        rResultado := rResultado::"Lot and Serial No."
                    ELSE
                        IF SiLote AND (NOT SiSerie) AND SiPack THEN
                            rResultado := rResultado::"Lot and Package No."
                        ELSE
                            IF SiLote AND (NOT SiSerie) AND (NOT SiPack) THEN
                                rResultado := rResultado::"Lot No."
                            ELSE
                                IF (NOT SiLote) AND SiSerie AND SiPack THEN
                                    rResultado := rResultado::"Serial and Package No."
                                ELSE
                                    IF (NOT SiLote) AND SiSerie AND (NOT SiPack) THEN
                                        rResultado := rResultado::"Serial No."
                                    ELSE
                                        IF (NOT SiLote) AND (NOT SiSerie) AND SiPack THEN
                                            rResultado := rResultado::"Package No.";

        end;
    END;





    #endregion

    #region DATOS JSON

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


    local procedure DatoJsonDecimal(xObjeto: JsonObject; xNodo: Text): Decimal
    var
        VJsonTokenParte: JsonToken;
        jVariable: Decimal;
    begin
        jVariable := 0;
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit(0)
            else begin
                jVariable := VJsonTokenParte.AsValue().AsDecimal();
                exit(jVariable);
            end;
        end else begin
            exit(0);
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

    local procedure DatoJsonDate(xObjeto: JsonObject; xNodo: Text): Date
    var
        VJsonTokenParte: JsonToken;
        jVariable: Date;
    begin
        jVariable := 0D;
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit(0D)
            else begin
                jVariable := VJsonTokenParte.AsValue().AsDate();
                exit(jVariable);
            end;
        end else begin
            exit(0D);
        end;
    end;


    local procedure DatoJsonBoolean(xObjeto: JsonObject; xNodo: Text): Boolean
    var
        VJsonTokenParte: JsonToken;
        vTexto: Text;
        jVariable: Boolean;
    begin
        jVariable := false;
        if xObjeto.Get(xNodo, VJsonTokenParte) then begin
            if VJsonTokenParte.AsValue().IsNull then
                exit(jVariable)
            else begin
                vTexto := VJsonTokenParte.AsValue().AsText();
                if (UpperCase(vTexto) = 'TRUE') OR (UpperCase(vTexto) = 'YES') then
                    jVariable := true;
                exit(jVariable);
            end;
        end else begin
            exit(jVariable);
        end;
    end;

    #endregion DATOS JSON

    #region FUNCIONES

    local procedure QuitarPunto(xValor: text): Text
    begin
        exit(xValor.Replace('.', ''));
    end;

    local procedure FormatoBoolean(xCampo: Boolean): Text
    var

    begin
        if xCampo then
            exit('True')
        else
            exit('False')
    end;

    local procedure FormatoFecha(xCampo: DateTime): Text
    var
    begin
        //EXIT(Format(xCampo, 10, '<day,2>/<month,2>/<year4>'));
        EXIT(Format(xCampo, 0, 9))
    end;

    local procedure FormatoFecha(xCampo: Date): Text
    var
    begin
        if xCampo <> 0D THEN
            //EXIT(Format(xCampo, 10, '<day,2>/<month,2>/<year4>'))
            EXIT(Format(xCampo, 0, 9))
        ELSE
            EXIT(Format('01/01/2000', 0, 9));
    end;

    local procedure FormatoNumero(xCampo: Decimal): Text
    var
    begin
        EXIT(Format(xCampo, 0, 9));
    end;

    local procedure FormatoNumero(xCampo: Integer): Text
    var
    begin
        EXIT(Format(xCampo, 0, 9));
        //EXIT(QuitarPunto(Format(xCampo)));
    end;



    local procedure QuitarCaracteresRaros(xOriginal: Text) xFinal: Text
    var
        Filtro1: Text;
        Filtro2: Text;
    begin
        Filtro1 := '()"&´/'; //'ÁÀÉÈÍÌÓÒÚÙÜ()"&´/'
        Filtro2 := '     -'; //'ÁÀÉÈÍÌÓÒÚÙÜ()"&´/'

        xFinal := CONVERTSTR(xOriginal, Filtro1, Filtro2);
    end;

    #endregion FUNCIONES

    var

        lblErrorJson: Label 'Incorrect format. A Json was expected', Comment = 'ESP=Formato incorrecto. Se esperaba un Json';
        lblErrorRecurso: Label 'The indicated resource was not found', Comment = 'ESP=No se ha encontrado el recurso indicado';
        lblErrorReferencia: Label 'Reference %1 not found in the system', Comment = 'ESP=No se ha encontrado la referencia %1 en el sistema';
        lblErrorCodSeguimiento: Label 'No product tracking code has been indicated for reference %1', Comment = 'ESP=No se ha indicado código seguimiento producto para la referencia %1';
        lblErrorRecepcion: Label 'Warehouse receipt with number %1 not found', Comment = 'ESP=No se ha encontrado la recepción con número %1';
        lblErrorLineasCantidad: Label 'There are no pending lines with sufficient quantity', Comment = 'ESP=No hay lineas pendientes con cantidad suficiente';
        lblErrorAlRecepcionar: Label 'Warehouse receipt error', Comment = 'ESP=Error en la recepción';
        lblErrorPrefijoLote: Label 'Lot prefix not defined', comment = 'ESP=No se ha definido el prefijo del lote';
        lblErrorNSerieLote: Label 'A serial number has not been defined to generate the batch', comment = 'ESP=No se ha definido un nº de serie para generar el lote';
        lblErrorSinReferencia: Label 'Item No field is empty', comment = 'ESP=El campo referencia está vacio';
        lblErrorLoteInterno: Label 'Error generating internal Lot No number', comment = 'ESP=Error al generar el número de lote interno';
        lblErrorLote: Label 'Lot No not defined', comment = 'ESP=No se ha definido el lote';
        lblErrorSerie: Label 'Serial No not defined', comment = 'ESP=No se ha definido el serie';
        lblErrorPaquete: Label 'Package No not defined', comment = 'ESP=No se ha definido el paquete';
        lblErrorPaqueteGenerico: Label 'Empty Package code not defined', comment = 'ESP=No se ha definido el código de paquete vacío';

        lblErrorLoteInternoNoExiste: Label 'Internal Lot No %1 was not found in the system', Comment = 'ESP=No se ha encontrado el lote interno %1 en el sistema';
        lblErrorSerieInternoNoExiste: Label 'Internal Serial No %1 was not found in the system', Comment = 'ESP=No se ha encontrado el serie interno %1 en el sistema';

        lblErrorRegistrar: Label 'Error posting', Comment = 'ESP=Error al registrar';
        lblErrorAlmacen: Label 'App Warehouse not defined', comment = 'ESP=No se ha definido el almacén de la App';
        lblErrorTrackNo: Label 'Track No. Not Found', Comment = 'ESP=No se ha encontrado la trazabilidad';
        lblPaquete: Label 'Package', Comment = 'ESP=Paquete';
        lblLote: Label 'Lot No', Comment = 'ESP=Lote';
        lblSerie: Label 'Serial No', Comment = 'ESP=Serie';
        lblReferencia: Label 'Item No.', Comment = 'ESP=Referencia';

        lblErrorDiarioInv: Label 'Journal Template Name not define on Warehouse Setup', comment = 'ESP=No se ha definido el diario inventario en la configuración de almacén';
        lblErrorUbicacion: Label 'Bin %1 not found', Comment = 'ESP=Ubicación %1 no encontrada';
        lblErrorUbicacionAjuste: Label 'Adjust bin not defined', comment = 'ESP="Ubicación de ajuste no definida"';
        lblErrorSinInventario: Label 'Inventory not found', comment = 'ESP="No existe inventario"';
        lblErrorSinAlmacenamiento: Label 'Put-away not found', comment = 'ESP="Almacenamiento no encontrado"';
        lblErrorSinMovimiento: Label 'Movement not found', comment = 'ESP="Movimiento no encontrado"';

        lblErrorNadaQueRegistrar: Label 'Nothing to handle.', comment = 'ESP="Nada que registrar"';
        lblErrorMover: Label 'Error when moving', comment = 'ESP="Error al mover"';
        lblErrorSegProd: Label 'Product tracking definition error', comment = 'ESP="Error en la definición del seguimiento de producto"';
        lblErrorSerialDuplicado: Label 'The serial number already exists in the systemr', comment = 'ESP="El número de serie ya existe en el sistema"';
        lblErrorSerialDuplicadoEnvio: Label 'The serial number already exists in one shipment', comment = 'ESP="El número de serie ya existe en un envío"';
        lblErrorSinSeriePaquete: Label 'Package Serial No not define on Warehouse Setup', comment = 'ESP=No se ha definido el nº de serie del en la configuración de almacén';

        lblErrorEnvio: Label 'Shipment Not Found', Comment = 'ESP=No se ha encontrado en envío';

}