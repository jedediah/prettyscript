#define tIGNORED_NL      (tLAST_TOKEN + 1)
#define tCOMMENT         (tLAST_TOKEN + 2)
#define tEMBDOC_BEG      (tLAST_TOKEN + 3)
#define tEMBDOC          (tLAST_TOKEN + 4)
#define tEMBDOC_END      (tLAST_TOKEN + 5)
#define tSP              (tLAST_TOKEN + 6)
#define tHEREDOC_BEG     (tLAST_TOKEN + 7)
#define tHEREDOC_END     (tLAST_TOKEN + 8)
#define k__END__         (tLAST_TOKEN + 9)

static ID pscript_id_backref;
static ID pscript_id_backtick;
static ID pscript_id_comma;
static ID pscript_id_const;
static ID pscript_id_cvar;
static ID pscript_id_embexpr_beg;
static ID pscript_id_embexpr_end;
static ID pscript_id_embvar;
static ID pscript_id_float;
static ID pscript_id_gvar;
static ID pscript_id_ident;
static ID pscript_id_int;
static ID pscript_id_ivar;
static ID pscript_id_kw;
static ID pscript_id_lbrace;
static ID pscript_id_lbracket;
static ID pscript_id_lparen;
static ID pscript_id_nl;
static ID pscript_id_op;
static ID pscript_id_period;
static ID pscript_id_rbrace;
static ID pscript_id_rbracket;
static ID pscript_id_rparen;
static ID pscript_id_semicolon;
static ID pscript_id_symbeg;
static ID pscript_id_tstring_beg;
static ID pscript_id_tstring_content;
static ID pscript_id_tstring_end;
static ID pscript_id_words_beg;
static ID pscript_id_qwords_beg;
static ID pscript_id_words_sep;
static ID pscript_id_regexp_beg;
static ID pscript_id_regexp_end;
static ID pscript_id_label;
static ID pscript_id_tlambda;
static ID pscript_id_tlambeg;

static ID pscript_id_ignored_nl;
static ID pscript_id_comment;
static ID pscript_id_embdoc_beg;
static ID pscript_id_embdoc;
static ID pscript_id_embdoc_end;
static ID pscript_id_sp;
static ID pscript_id_heredoc_beg;
static ID pscript_id_heredoc_end;
static ID pscript_id___end__;
static ID pscript_id_CHAR;

#include "eventids2table.c"

static void
pscript_init_eventids2(VALUE self)
{
    pscript_id_backref = rb_intern_const("on_backref");
    pscript_id_backtick = rb_intern_const("on_backtick");
    pscript_id_comma = rb_intern_const("on_comma");
    pscript_id_const = rb_intern_const("on_const");
    pscript_id_cvar = rb_intern_const("on_cvar");
    pscript_id_embexpr_beg = rb_intern_const("on_embexpr_beg");
    pscript_id_embexpr_end = rb_intern_const("on_embexpr_end");
    pscript_id_embvar = rb_intern_const("on_embvar");
    pscript_id_float = rb_intern_const("on_float");
    pscript_id_gvar = rb_intern_const("on_gvar");
    pscript_id_ident = rb_intern_const("on_ident");
    pscript_id_int = rb_intern_const("on_int");
    pscript_id_ivar = rb_intern_const("on_ivar");
    pscript_id_kw = rb_intern_const("on_kw");
    pscript_id_lbrace = rb_intern_const("on_lbrace");
    pscript_id_lbracket = rb_intern_const("on_lbracket");
    pscript_id_lparen = rb_intern_const("on_lparen");
    pscript_id_nl = rb_intern_const("on_nl");
    pscript_id_op = rb_intern_const("on_op");
    pscript_id_period = rb_intern_const("on_period");
    pscript_id_rbrace = rb_intern_const("on_rbrace");
    pscript_id_rbracket = rb_intern_const("on_rbracket");
    pscript_id_rparen = rb_intern_const("on_rparen");
    pscript_id_semicolon = rb_intern_const("on_semicolon");
    pscript_id_symbeg = rb_intern_const("on_symbeg");
    pscript_id_tstring_beg = rb_intern_const("on_tstring_beg");
    pscript_id_tstring_content = rb_intern_const("on_tstring_content");
    pscript_id_tstring_end = rb_intern_const("on_tstring_end");
    pscript_id_words_beg = rb_intern_const("on_words_beg");
    pscript_id_qwords_beg = rb_intern_const("on_qwords_beg");
    pscript_id_words_sep = rb_intern_const("on_words_sep");
    pscript_id_regexp_beg = rb_intern_const("on_regexp_beg");
    pscript_id_regexp_end = rb_intern_const("on_regexp_end");
    pscript_id_label = rb_intern_const("on_label");
    pscript_id_tlambda = rb_intern_const("on_tlambda");
    pscript_id_tlambeg = rb_intern_const("on_tlambeg");

    pscript_id_ignored_nl = rb_intern_const("on_ignored_nl");
    pscript_id_comment = rb_intern_const("on_comment");
    pscript_id_embdoc_beg = rb_intern_const("on_embdoc_beg");
    pscript_id_embdoc = rb_intern_const("on_embdoc");
    pscript_id_embdoc_end = rb_intern_const("on_embdoc_end");
    pscript_id_sp = rb_intern_const("on_sp");
    pscript_id_heredoc_beg = rb_intern_const("on_heredoc_beg");
    pscript_id_heredoc_end = rb_intern_const("on_heredoc_end");
    pscript_id___end__ = rb_intern_const("on___end__");
    pscript_id_CHAR = rb_intern_const("on_CHAR");

    pscript_init_eventids2_table(self);
}

static const struct token_assoc {
    int token;
    ID *id;
} token_to_eventid[] = {
    {' ',		&pscript_id_words_sep},
    {'!',		&pscript_id_op},
    {'%',		&pscript_id_op},
    {'&',		&pscript_id_op},
    {'*',		&pscript_id_op},
    {'+',		&pscript_id_op},
    {'-',		&pscript_id_op},
    {'/',		&pscript_id_op},
    {'<',		&pscript_id_op},
    {'=',		&pscript_id_op},
    {'>',		&pscript_id_op},
    {'?',		&pscript_id_op},
    {'^',		&pscript_id_op},
    {'|',		&pscript_id_op},
    {'~',		&pscript_id_op},
    {':',		&pscript_id_op},
    {',',		&pscript_id_comma},
    {'.',		&pscript_id_period},
    {';',		&pscript_id_semicolon},
    {'`',		&pscript_id_backtick},
    {'\n',              &pscript_id_nl},
    {keyword_alias,	&pscript_id_kw},
    {keyword_and,	&pscript_id_kw},
    {keyword_begin,	&pscript_id_kw},
    {keyword_break,	&pscript_id_kw},
    {keyword_case,	&pscript_id_kw},
    {keyword_class,	&pscript_id_kw},
    {keyword_def,	&pscript_id_kw},
    {keyword_defined,	&pscript_id_kw},
    {keyword_do,	&pscript_id_kw},
    {keyword_do_block,	&pscript_id_kw},
    {keyword_do_cond,	&pscript_id_kw},
    {keyword_else,	&pscript_id_kw},
    {keyword_elsif,	&pscript_id_kw},
    {keyword_end,	&pscript_id_kw},
    {keyword_ensure,	&pscript_id_kw},
    {keyword_false,	&pscript_id_kw},
    {keyword_for,	&pscript_id_kw},
    {keyword_if,	&pscript_id_kw},
    {modifier_if,	&pscript_id_kw},
    {keyword_in,	&pscript_id_kw},
    {keyword_module,	&pscript_id_kw},
    {keyword_next,	&pscript_id_kw},
    {keyword_nil,	&pscript_id_kw},
    {keyword_not,	&pscript_id_kw},
    {keyword_or,	&pscript_id_kw},
    {keyword_redo,	&pscript_id_kw},
    {keyword_rescue,	&pscript_id_kw},
    {modifier_rescue,	&pscript_id_kw},
    {keyword_retry,	&pscript_id_kw},
    {keyword_return,	&pscript_id_kw},
    {keyword_self,	&pscript_id_kw},
    {keyword_super,	&pscript_id_kw},
    {keyword_then,	&pscript_id_kw},
    {keyword_true,	&pscript_id_kw},
    {keyword_undef,	&pscript_id_kw},
    {keyword_unless,	&pscript_id_kw},
    {modifier_unless,	&pscript_id_kw},
    {keyword_until,	&pscript_id_kw},
    {modifier_until,	&pscript_id_kw},
    {keyword_when,	&pscript_id_kw},
    {keyword_while,	&pscript_id_kw},
    {modifier_while,	&pscript_id_kw},
    {keyword_yield,	&pscript_id_kw},
    {keyword__FILE__,	&pscript_id_kw},
    {keyword__LINE__,	&pscript_id_kw},
    {keyword__ENCODING__, &pscript_id_kw},
    {keyword_BEGIN,	&pscript_id_kw},
    {keyword_END,	&pscript_id_kw},
    {keyword_do_LAMBDA,	&pscript_id_kw},
    {tAMPER,		&pscript_id_op},
    {tANDOP,		&pscript_id_op},
    {tAREF,		&pscript_id_op},
    {tASET,		&pscript_id_op},
    {tASSOC,		&pscript_id_op},
    {tBACK_REF,		&pscript_id_backref},
    {tCHAR,		&pscript_id_CHAR},
    {tCMP,		&pscript_id_op},
    {tCOLON2,		&pscript_id_op},
    {tCOLON3,		&pscript_id_op},
    {tCONSTANT,		&pscript_id_const},
    {tCVAR,		&pscript_id_cvar},
    {tDOT2,		&pscript_id_op},
    {tDOT3,		&pscript_id_op},
    {tEQ,		&pscript_id_op},
    {tEQQ,		&pscript_id_op},
    {tFID,		&pscript_id_ident},
    {tFLOAT,		&pscript_id_float},
    {tGEQ,		&pscript_id_op},
    {tGVAR,		&pscript_id_gvar},
    {tIDENTIFIER,	&pscript_id_ident},
    {tINTEGER,		&pscript_id_int},
    {tIVAR,		&pscript_id_ivar},
    {tLBRACE,		&pscript_id_lbrace},
    {tLBRACE_ARG,	&pscript_id_lbrace},
    {'{',       	&pscript_id_lbrace},
    {'}',       	&pscript_id_rbrace},
    {tLBRACK,		&pscript_id_lbracket},
    {'[',       	&pscript_id_lbracket},
    {']',       	&pscript_id_rbracket},
    {tLEQ,		&pscript_id_op},
    {tLPAREN,		&pscript_id_lparen},
    {tLPAREN_ARG,	&pscript_id_lparen},
    {'(',		&pscript_id_lparen},
    {')',		&pscript_id_rparen},
    {tLSHFT,		&pscript_id_op},
    {tMATCH,		&pscript_id_op},
    {tNEQ,		&pscript_id_op},
    {tNMATCH,		&pscript_id_op},
    {tNTH_REF,		&pscript_id_backref},
    {tOP_ASGN,		&pscript_id_op},
    {tOROP,		&pscript_id_op},
    {tPOW,		&pscript_id_op},
    {tQWORDS_BEG,	&pscript_id_qwords_beg},
    {tREGEXP_BEG,	&pscript_id_regexp_beg},
    {tREGEXP_END,	&pscript_id_regexp_end},
    {tRPAREN,		&pscript_id_rparen},
    {tRSHFT,		&pscript_id_op},
    {tSTAR,		&pscript_id_op},
    {tSTRING_BEG,	&pscript_id_tstring_beg},
    {tSTRING_CONTENT,	&pscript_id_tstring_content},
    {tSTRING_DBEG,	&pscript_id_embexpr_beg},
    {tSTRING_DVAR,	&pscript_id_embvar},
    {tSTRING_END,	&pscript_id_tstring_end},
    {tSYMBEG,		&pscript_id_symbeg},
    {tUMINUS,		&pscript_id_op},
    {tUMINUS_NUM,	&pscript_id_op},
    {tUPLUS,		&pscript_id_op},
    {tWORDS_BEG,	&pscript_id_words_beg},
    {tXSTRING_BEG,	&pscript_id_backtick},
    {tLABEL,		&pscript_id_label},
    {tLAMBDA,		&pscript_id_tlambda},
    {tLAMBEG,		&pscript_id_tlambeg},

    /* pscript specific tokens */
    {tIGNORED_NL,       &pscript_id_ignored_nl},
    {tCOMMENT,          &pscript_id_comment},
    {tEMBDOC_BEG,       &pscript_id_embdoc_beg},
    {tEMBDOC,           &pscript_id_embdoc},
    {tEMBDOC_END,       &pscript_id_embdoc_end},
    {tSP,               &pscript_id_sp},
    {tHEREDOC_BEG,      &pscript_id_heredoc_beg},
    {tHEREDOC_END,      &pscript_id_heredoc_end},
    {k__END__,          &pscript_id___end__},
    {0, NULL}
};

static ID
pscript_token2eventid(int tok)
{
    const struct token_assoc *a;

    for (a = token_to_eventid; a->id != NULL; a++) {
        if (a->token == tok)
            return *a->id;
    }
    if (tok < 256) {
        return pscript_id_CHAR;
    }
    rb_raise(rb_eRuntimeError, "[PrettyScript FATAL] unknown token %d", tok);
}
