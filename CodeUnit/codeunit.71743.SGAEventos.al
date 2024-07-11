codeunit 71743 "SGA Eventos"
{

    trigger OnRun()
    begin

    end;

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
        //WhseReceiptLine2.SetRange("Line No.", WhseReceiptLine."Line No.");
        IF NOT WhseReceiptLine2.FindSet() then exit;

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

        repeat

            WhseReceiptLine2."Qty. to Receive" := TrackLine."Qty. to Handle";
            WhseReceiptLine2."Qty. to Receive (Base)" := TrackLine."Qty. to Handle (Base)";
            WhseReceiptLine2.Modify;

        until WhseReceiptLine2.Next() = 0;

    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnAfterPostSourceDocument', '', false, false)]
    local procedure OnAfterPostWhseJnlLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line")
    var
        WarehouseSetup: record "Warehouse Setup";
        WhseReceiptLine2: Record "Warehouse Receipt Line";
        TrackLine: record "Tracking Specification";

    begin
        WhseReceiptLine2.reset;
        WhseReceiptLine2.SetRange("No.", WarehouseReceiptLine."No.");
        //WhseReceiptLine2.SetRange("Line No.", WarehouseReceiptLine."Line No.");
        IF NOT WhseReceiptLine2.FindSet() then exit;

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

        repeat

            WhseReceiptLine2."Qty. to Receive" := TrackLine."Qty. to Handle";
            WhseReceiptLine2."Qty. to Receive (Base)" := TrackLine."Qty. to Handle (Base)";
            WhseReceiptLine2.Modify;

        until WhseReceiptLine2.Next() = 0;

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

}
