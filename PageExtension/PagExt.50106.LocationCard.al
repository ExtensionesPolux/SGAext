pageextension 50106 LocationCard extends "Location Card"
{
    layout
    {
        addafter(Bins)
        {
            group(App)
            {
                Caption = 'Aplicación SGA';
                field("Almacenamiento automatico"; Rec."Almacenamiento automatico")
                {
                    ApplicationArea = all;
                }
                field("Zona Recepcionados"; Rec."Zona Recepcionados")
                {
                    ApplicationArea = all;
                }
                field("Ubicacion Recepcionados"; Rec."Ubicacion Recepcionados")
                {
                    ApplicationArea = all;
                }


                field("Almacen Avanzado"; Rec."Almacen Avanzado")
                {
                    ApplicationArea = all;
                }
                field(AppInvJournalTemplateName; Rec.AppInvJournalTemplateName)
                {
                    ApplicationArea = all;
                }
                field(AppInvJournalBatchName; Rec.AppInvJournalBatchName)
                {
                    ApplicationArea = all;
                }
                field(SumarCantidad; Rec.SumarCantidad)
                {
                    ApplicationArea = all;
                }

            }

        }
    }
}