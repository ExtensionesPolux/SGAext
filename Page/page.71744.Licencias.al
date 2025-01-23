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
                    LicenseMgt.Registro('O8JmtY03KyuZNNVohiImwxegnn+P5epppLfoLZG/dZ3icMwq+rUlnzhrLfYhO435lxbY/EJEXdZb68zJhseYfwClnH758cfnLnbSos0K2/irr/AZYOlyNnrKvS08ZcRoc7PqNozUt5VshcO9X7hDz3+3hMwAfaICt4ImmN1EC2vzJHqseT6Z51FwRTZVCGAQldtzL7Tl/whgp7+Sq1hPh2r8ZopOwBrPjzFAwRg6/3Q=')
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
            action(DELETEALL)
            {
                ApplicationArea = all;
                Caption = 'Eliminar Registros Tablas';
                Image = Delete;

                trigger OnAction()
                var
                    RecDispositivos: Record Dispositivos;
                begin
                    Clear(RecDispositivos);
                    RecDispositivos.SetRange(Baja, true);
                    IF RecDispositivos.FindSet() then
                        if Dialog.Confirm('Se van a eliminar los dispositivos dados de baja') then
                            RecDispositivos.DeleteAll();
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

    trigger OnAfterGetRecord()
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