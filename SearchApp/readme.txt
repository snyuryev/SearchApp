
Simple search application.

Provides search through given source text (in current application text is included to the main bundle). It uses regular expressions.
Also it provides lemmatisation (for simple forms like plural numbers: federal-federals or for symbols: p-§.
It uses synonyms list from file (like fed-federal, sec-section). Search results will be displayed in the table view.
Also the search has small config with flags like MATCH_WINDOW (max text range for matching) or MAX_HITS (how many search results will be returned).
In search results we can prepare short snippet for displaying it. Searching results will be colored with red color.


Here just short list of examples which you can use for searching:

Fed
Federal
Federals
Federal state
State federal
State fed
s
sect
section