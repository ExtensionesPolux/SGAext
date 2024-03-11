page 71748 "Filtro Inventario"
{

    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Location; vLocatiom)
                {
                    ApplicationArea = All;
                    Caption = 'Almacen';
                    TableRelation = Location.Code;
                }
            }
        }
    }

    procedure Valor_Almacen(): Text;
    var
        myInt: Integer;
    begin
        exit(vLocatiom);
    end;

    var
        vLocatiom: Text;

}