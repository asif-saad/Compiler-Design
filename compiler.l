%{
	int if_check=0;
	int else_check=0;
	int while_loop_check=0;
	int top_stack=-1;
	char stack[1000];
	FILE *fptr1;

%}

dtypes 4bytes|l4bytes|f4bytes|8bytes|16bits|cbyt
bin_op "_add_"|"_sub_"|"_mul_"|"_div_"|"_remainder_"
rel_op "<<<"|">>>"|"<<="|"=>>"|"_equalEQUAL_"|"_notEqual_"
log_op "_and_"|"_or_"|"_not_"
variable ([a-zA-Z0-9]+)|([a-zA-Z0-9]+"["[0-9]+"]")
integer		[-+]?[0-9]+	
float		[-+]?([0-9])+"."([0-9])*
if__else "assume"|"unless"
inc__dec	"++"|"--"
number		([-+]?[0-9]*)|([-+]?([0-9])+"."([0-9])*)
array		[a-zA-Z0-9]+"["[0-9]+"]"	
var_or_num		([a-zA-Z0-9]+)|([-+]?[0-9]*)|([-+]?([0-9])+"."([0-9])*)


/* add code section begining and ending check */
%%

"yield"([ ][0-9]+)? {
	fprintf(fptr1,"returning from the current context ");
    printf("returning from the current context ");
	return 0;
}
"protocol "{variable}"{"([ \n]*{dtypes}" "({variable}|({variable}"="{number}))";"[ \n]*)+"}" /* strcture creation*/{
	fprintf(fptr1,"Protocol named: '");
	printf("Protocol named: '");
	int flag=0,cnt=0;
	for(int i=0;i<yyleng;i++){
		if(yytext[i]=='{'){
			break;
		}
		if(flag==1){
			fprintf(fptr1,"%c",yytext[i]);
			printf("%c",yytext[i]);
		}
		if(yytext[i]==' ')
		{
			flag=1;
		}
	}
	fprintf(fptr1,"' created");
	printf("' created");
	for(int i=0;i<yyleng;i++){
		if(yytext[i]==';'){
			cnt++;
		}
	}
	fprintf(fptr1," with %d variables\n",cnt);
	printf(" with %d variables",cnt);
}
"protocol "{variable}" "{variable} /*structure variable created*/{
	fprintf(fptr1,"protocol of type:'");
	printf("protocol of type:'");
	int flag=0,index=0;
	for(int i=0;i<yyleng;i++){
		if(yytext[i]==' '){
			index=i;
			index++;
			break;
		}
	}
	for(int i=index;i<yyleng;i++){
		if(yytext[i]==' '){
			
			index=i;
			index++;
			break;
		}
		fprintf(fptr1,"%c",yytext[i]);
		printf("%c",yytext[i]);
	}
	fprintf(fptr1,"' variable:'");
	printf("' variable:'");
	for(int i=index;i<yyleng;i++)
	{
		fprintf(fptr1,"%c",yytext[i]);
		printf("%c",yytext[i]);
	}
	fprintf(fptr1,"' declared\n");
	printf("' declared");
}
{variable}"."{variable}"="({number}|"'"[a-zA-Z]"'") /* structure member accessing*/{
	int flag=0;
	for(int i=0;i<yyleng;i++){
		if(yytext[i]=='='){
			break;
		}
		if(flag==1){
			fprintf(fptr1,"%c\n",yytext[i]);
			printf("%c",yytext[i]);
		}
		if(yytext[i]=='.'){
			flag=1;
		}
	}
}
[{}] {
	char a=stack[top_stack];
	fprintf(fptr1,"\t");
	while(1==1)
	{
		if(a=='w'){
			fprintf(fptr1,"while loop");
			printf("while loop");
		}
		if(a=='f'){
			fprintf(fptr1,"function");
			printf("function");
		}
		if(a=='a'){
			fprintf(fptr1,"if block");
			printf("if block");
		}
		if(a=='u'){
			fprintf(fptr1,"else if block");
			printf("else if block");
		}
		if(a=='o'){
			fprintf(fptr1,"else block");
			printf("else block");
		}
		break;
	}
	if(yytext[0]=='{'){
		fprintf(fptr1," body section begins\n");
		printf(" body section begins");
	}
	else{
		top_stack--;
		fprintf(fptr1," ended\n");
		printf(" ended");
	}
}
#{2}[^\n]+ /* single line comment */{
	fprintf(fptr1,"single line comment\n");
    printf("single line comment");
}
{dtypes}[' ']+{variable} /* variable declared */ {
    if(yytext[0]=='4')
    {
		fprintf(fptr1,"integer variable declared");
        printf("integer variable declared");
    }
	if(yytext[0]=='l')
    {
		fprintf(fptr1,"long variable declared");
        printf("long variable declared");
    }
	if(yytext[0]=='f')
    {
		fprintf(fptr1,"float variable declared");
        printf("float variable declared");
    }
	if(yytext[0]=='8')
    {
		fprintf(fptr1,"double variable declared");
        printf("double variable declared");
    }
	if(yytext[0]=='1')
    {
		fprintf(fptr1,"short datatype variable declared");
        printf("short datatype variable declared");
    }
	fprintf(fptr1,"\n");
	
}
{variable}"="(({variable}|{number})|({variable}{bin_op}({variable}|{number}))) /* variable initialisation*/ {
	int flag=0;
	for(int i=0;i<yyleng;i++)
	{
		if(yytext[i]=='[')
		{
			fprintf(fptr1,"array cell initialisation");
			printf("array cell initialisation");
			flag=1;
			break;
		}
	}
	if(flag==0){
		fprintf(fptr1,"variable initialisation\n");
			printf("variable initialisation");
		}
	
}
{if__else}"("{variable}{rel_op}({variable}|{number}|({variable}{bin_op}({variable}|{number})))")" /*if else statement*/{
	if(yytext[0]=='a') /*checking if block, and incrementing if_check*/
	{
		if_check++;
		fprintf(fptr1,"if block stated\n");
		printf("if block stated");
		top_stack++;
		stack[top_stack]='a';
	}
	if(yytext[0]=='u') /* else if, will be showing error message if no immediate if block exists */
	{
		if(if_check<1)
		{
			fprintf(fptr1,"else if block without any immediate if block!!!\n");
			printf("else if block without any immediate if block!!!");
		}
		else{
			top_stack++;
			stack[top_stack]='u';
			fprintf(fptr1,"else if block stated\n");
			printf("else if block stated");
		}
	}
	
}
"#*" /*multi line comment*/{
	int comment_line = 1;
	int end=0;
	char c=input();
	while(1==1)
	{
		if(c=='\n')
		{
			++comment_line;
			//for no reason
		}
		if(c=='*')
		{
			char a=c;
			c=input();
			if(c=='#'){
				end=1;
				break;
			}
		}
		else{
			c=input();
		}

	}
	fprintf(fptr1,"number of muliline comments: %d\n",comment_line);
	printf("number of muliline comments: %d\t",comment_line);
	fprintf(fptr1,"multi-line comment ended\n");
	printf("multi-line comment ended");
}
{variable}"="({variable}|{number}){bin_op}({variable}|{number}) /* arithmetic operation */ {
	for(int i=0;i<yyleng;i++)
	{
		if(yytext[i]=='_' && yytext[i+1]=='a'){
			fprintf(fptr1,"addition operation");
			printf("addition operation");
		}
		if(yytext[i]=='_' && yytext[i+1]=='s'){
			fprintf(fptr1,"subtraction operation");
			printf("subtraction operation");
		}
		if(yytext[i]=='_' && yytext[i+1]=='m'){
			fprintf(fptr1,"multiplication operation");
			printf("multiplication operation");
		}
		if(yytext[i]=='_' && yytext[i+1]=='d'){
			fprintf(fptr1,"division operation");
			printf("division operation");
		}
		if(yytext[i]=='_' && yytext[i+1]=='r'){
			fprintf(fptr1,"remainder operation");
			printf("remainder operation");
		}
		fprintf(fptr1,"\n");
	}
}
{variable}{inc__dec} /* increment decrement */ {
	for(int i=0;i<yyleng;i++)
	{
		if(yytext[i]=='+' && yytext[i+1]=='+')
		{
			fprintf(fptr1,"increment operation");
			printf("increment operation");
			break;
		}
		if(yytext[i]=='-' && yytext[i+1]=='-')
		{
			fprintf(fptr1,"decrement operation");
			printf("decrement operation");
			break;
		}
		fprintf(fptr1,"\n");
	}
}
otherwise /* else section */ {
	fprintf(fptr1,"else section begins\n");
	printf("else section begins");
	top_stack++;
	stack[top_stack]='o';
}
"when "(({variable}|{number}){rel_op}(({variable}{bin_op}({number}|{variable}))|{number}|({number}{bin_op}{number})))","{variable}{bin_op}"="({variable}|{integer})";" {
	fprintf(fptr1,"while loop started\n");
	printf("while loop started");
	while_loop_check++;
	top_stack++;
	stack[top_stack]='w';
}
"scan(&"{variable}")" /*input from console*/ {
	fprintf(fptr1,"input from console --> '");
	printf("input from console --> '");
	int flag=0;
	for(int i=0;i<yyleng;i++)
	{
		if(yytext[i]==')')
		{
			break;
		}
		if(flag==1)
		{
			fprintf(fptr1,"%c",yytext[i]);
			printf("%c",yytext[i]);
		}
		if(yytext[i]=='&')
		{
			flag=1;
		}
	}
	fprintf(fptr1,"' variable\n");
	printf("' variable");
}
"print("{variable}")" /*output to console*/ {
	fprintf(fptr1,"value in console --> '");
	printf("value in console --> '");
	int flag=0;
	for(int i=0;i<yyleng;i++)
	{
		if(yytext[i]==')')
		{
			break;
		}
		if(flag==1)
		{
			fprintf(fptr1,"%c",yytext[i]);
			printf("%c",yytext[i]);
		}
		if(yytext[i]=='(')
		{
			flag=1;
		}
	}
	fprintf(fptr1,"' variable\n");
	printf("' variable");
}
({dtypes}|"nullified")" func "{variable}"("({dtypes}" "{variable}("="{number}",")?)*")" /*function*/ {
    top_stack++;
	stack[top_stack]='f';
	fprintf(fptr1,"declaring func named:  '");
	printf("declaring func named:  '");
	int flag=0;
	int index=0;
	for(int i=0;i<yyleng;i++)
	{
		if(yytext[i]==' '){
			index=i;
			index++;
			break;
		}
	}
	for(int i=index;i<yyleng;i++)
	{
		if(yytext[i]=='('){
			break;
		}
		if(flag==1){
			fprintf(fptr1,"%c",yytext[i]);
			printf("%c",yytext[i]);
		}
		if(yytext[i]==' '){
			flag=1;
		}
	}
	
	fprintf(fptr1,"' with return type:");
	printf("' with return type:");
	if(yytext[0]=='n'){
		fprintf(fptr1,"void");
		printf("void");
	}
	if(yytext[0]=='4')
    {
		fprintf(fptr1,"integer");
        printf("integer");
    }
	if(yytext[0]=='l')
    {
		fprintf(fptr1,"long");
        printf("long");
    }
	if(yytext[0]=='f')
    {
		fprintf(fptr1,"float");
        printf("float");
    }
	if(yytext[0]=='8')
    {
		fprintf(fptr1,"double");
        printf("double");
    }
	if(yytext[0]=='1')
    {
		fprintf(fptr1,"short datatype");
        printf("short datatype");
    }
	index=0;
	for(int i=0;i<yyleng;i++)
	{
		if(yytext[i]==',')
		{
			index++;
		}
	}
	fprintf(fptr1," and %d parameters\n",index);
	printf(" and %d parameters",index);
}
[^\n\t ]+ {
	for(int i=0;i<5;i++)
	{
		fprintf(fptr1,"\nsyntactical error\n");
		printf("\nsyntactical error\n");
	}
	return 0;
}
%%

int yywrap(){
    return 1;
}

int main()
{
    FILE *fptr;
    fptr=fopen("input.txt","r");
	fptr1=fopen("output.txt","w");
    yyrestart(fptr);
    yylex();
}