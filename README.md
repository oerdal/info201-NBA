# Final Project

### Shiny Deployment

Project currently live on [>> shinyapps.io <<](https://jonah555.shinyapps.io/info201-NBA/)

# Fantasy Basketball Roster 
### Executive Summary 
Our group are working with an app associated with NBA, which is the most attractive basketball League in America. We made this app because we really care and love the NBA. And we want to make usage of mass statistics to visualize NBA market for NBA fans.  For this project, we make a shiny app that will display stats and prediction future stats of NBA players. 

### Detail
#### First Tab: PLAYER ROSTER
In this Shiny app, we collect data from all 507 current players and make a list called Fantasy Basketball Roster as you can see. We update all aspects of stats from players for this season. On the top, there is a mode option. Under the totals mode, people can see any single players totally cumulative statistics in all games they have played till now in this season games. And when switching to Average mode, it is clear to show some average statistics for players which is an assessment to players when trade happens in NBA. The second widget is called Team. It is obvious that people can track players by the teams they belong to. And we abbreviated 30 teams name into letters. Like HOU to stand for Houston Rockets, GSW for Golden State Warriors. It is straight-forward and convenient when people want to see statistics of players from a single team. The third widget is called position. As we know, we also categorize all players by their positions on the court. People can easily filter out the top scoring players in every position by selecting one position once a time. For example, when I choose SG in position, it will show me all players from Shooting Guards. And I arrange this players by single variable of points they have already got in a decreasing order, and then I could know James Harden leads in scoring in SG position. Moreover, people can easily change amount of entries shown by select different number. They can also search specific player in check box on the right. 

The number before player name is their jersey number. Team stands for the NBA team they play for. POS stands for position on court. GP means game played in this season. MIN means the minutes??? players show up on court. FG% stands for Field Goal Percentage and FT% is Field Attempt Percentage. 3PM means amount of three pointers made. REB stands for Rebounds. AST stands for Assist. STL is Steal. BLK is Block. PTS means the points players get. TOV means turnovers. +/- means players` contribution to game. + stands for positive contribution.


#### Second Tab: TRADE COMPARISON 
In second tab, we made a tool called Trading Comparison Tool in which we can simulate trade of players in NBA and to see the benefits for each team in the categories shown after current trade. There are two columns on each side stands for two teams that would trade players from each other. The chart in the middle show the benefiting result of trade in the form of bar pattern which stand for the comparison difference in each category. When bar in a specific category goes towards positive, it means Team 2 will benefit in this category. Otherwise, it will benefit Team 1.  There are two player rosters below the chart in which we can choose traded player from. Same as first tab, the trading tool also allow people to adjust amount of entries and search for specific player by name. 
