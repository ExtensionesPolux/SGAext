page 71744 Licencias
{
    PageType = list;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = Dispositivos;
    Permissions = tabledata Dispositivos = RMID;
    DeleteAllowed = false;
    ModifyAllowed = False;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(Datos)
            {
                field(LicenciasNo; CompanyInfo."Licencias Activas")
                { }
                field(LicenciasUsadas; CompanyInfo."Licencias Usadas")
                { }
                field(FechaVto; CompanyInfo."Fecha Vto Licencias")
                { }
            }
            repeater(Control1)
            {
                field(Device; rec.Code)
                {
                    Caption = 'Id Dispositivo';
                    ApplicationArea = all;
                }

                field(IP; rec.IP)
                {
                    ApplicationArea = all;
                }
                field("Posting Date"; rec."posting Date")
                {
                    ApplicationArea = all;
                }
            }
        }

        area(FactBoxes)
        {
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestAPI)
            {
                ApplicationArea = All;
                Caption = 'Hello Word';
                image = LinkWeb;
                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management";
                begin
                    LicenseMgt.Test_Hola();
                end;
            }

            action(Informacion)
            {
                ApplicationArea = all;
                Caption = 'Cargar Datos';
                image = Info;

                trigger OnAction()
                begin
                    Cargar_Datos();
                    CompanyInfo.Reset;
                    CompanyInfo.Findfirst;
                    CurrPage.Update(false);
                end;
            }

            action(MOTD)
            {
                ApplicationArea = All;
                Caption = 'Mensaje del día';
                image = ExportMessage;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management";
                begin
                    MESSAGE(LicenseMgt.MOTD(rec.Code));
                end;
            }
            action(DELETE)
            {
                ApplicationArea = all;
                Caption = 'Eliminar Registro';
                Image = DeleteRow;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management";
                begin
                    MESSAGE(LicenseMgt.MOTD(rec.Code));
                    CurrPage.update;
                end;

            }


        }
    }

    trigger OnOpenPage()
    begin
        Cargar_Datos();
        CompanyInfo.Reset;
        CompanyInfo.Findfirst;
    end;

    var
        CompanyInfo: record "Company Information";


    local procedure Cargar_Datos()
    var
        LicenseMgt: Codeunit "SGA License Management";
    begin
        LicenseMgt.Informacion();

        rec.reset;
        rec.FindFirst();
    end;

}