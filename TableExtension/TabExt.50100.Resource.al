tableextension 50100 Resource extends Resource
{
    fields
    {

        field(50000; Pin; code[10])
        {
            Caption = 'Pin to access', comment = 'ESP="Pin de acceso"';
            trigger OnValidate()
            var
                lblErrorLong: Label 'The pin must have at least 4 characters', Comment = 'ESP=El pin ha de tener al menos 4 carácteres';
            begin
                IF strlen(Pin) < 4 then error(lblErrorLong);
            end;
        }
        field(50001; "Permite Copiar"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Copy Allow', Comment = 'ESP=Permitir Copiar';
        }
        field(50002; "Permite Regularizar"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allows regularization', Comment = 'ESP=Permitir regularizar';
        }

        field(50010; "Ver cantidad inventario"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'View inventory quantity', Comment = 'ESP=Mostrar Cantidad inventario';
        }

    }

}