%define header 0

%macro colon 2
    %ifstr %1
        %ifid %2
            %2:
                dq header
                db %1, 0
        %else
            %error "Incorrect label"
        %endif
    %else
        %error "Incorrect data"
    %endif
    %define header %2
%endmacro
