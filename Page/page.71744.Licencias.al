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
                field(Baja; rec.Baja)
                {
                    ApplicationArea = All;
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
            action(REGISTER)
            {
                ApplicationArea = All;
                Caption = 'Prueba Registro';
                image = Register;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management";
                begin
                    LicenseMgt.Registro('+NHBrvhSau5AXed+gV4tCPoRW/JFf0ZnzH2gZJiuuYafC/rNB7n0gxNWqrAs2vZwXZgMewwVak35PdgnxdbIC4QVg4lX+vwjC/pUJ+eDrXCDxX7Q+v6lIUKpydAr3zy3oQjQO0pnAuotffaBa7n8VBghPHMnFcPWsP3LTjPwvBanubbanoUX5Zs3W1HbMUpLamVhUebg8oPOxHIDXQ7kPwN1MTuntcTsZmqZ6GKctvE=')
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
                    LicenseMgt.Eliminar_Registro_BC(rec.Code);
                    Cargar_Datos();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
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
        //rec.setrange(Baja, False);
        rec.FindFirst();
    end;

}