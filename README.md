
# Are You My Brother?: Identifying NBA Teams Who Use Their G-League Affiliate Strategically

<!-- badges: start -->
<!-- badges: end -->

## Abstract
This study compares the playing styles of NBA teams and their affiliated G-League teams. Specifically, it examines whether the developmental teams follow the same strategic approaches as their parent organizations. The G-League is becoming increasingly important for developing players and finding new ones. Understanding the alignment in playing styles across different levels can help foster organizational cohesion and enhance player growth and readiness.

## Problem Statement

If NBA and G-League teams share the same basketball mindset, it will help players prepare for the next level and improve their strategy execution. However, the extent to which G-League teams replicate the playing style of their NBA affiliates remains to be determined. This study aims to answer the question: "Do G-League teams play the same style of basketball as their affiliated NBA teams?"

## Hypotheses

- **Null Hypothesis (H₀):** There is no significant difference in the playing styles of NBA teams and their G-League affiliates.

- **Alternative Hypothesis (H₁):** There are significant differences in the playing styles of NBA teams and their G-League affiliates.

## Methodology

The following playing styles will be used to group the NBA and G-League teams: Fast-Paced, Defensive-Oriented, Three-Point Heavy, Iso-Heavy, Big-Man Centric, Motion Offense, Grit-and-Grind, Switch-Heavy Defense, Balanced/Adaptive, and Post-Up and Inside. 
Statistical analysis will rely on public game data from NBA and G-League seasons, covering metrics like pace, defensive rating, offensive efficiency, shot selection, and lineup compositions. 
Machine learning clustering techniques will be used to group teams according to their playing styles, after which similarity measures (such as cosine similarity or Euclidean distance) will be employed to evaluate the stylistic resemblance between G-League and NBA teams.

## Expanded Definition of Play Styles

To enhance the analysis, we categorize playing styles based on the following definitions derived from game statistics:

1. Fast-Paced: 
Teams identified as "Fast-Paced" exhibit a pace rating greater than 100 and score more than 15% of their points from fast breaks (`FB_PTS% > 0.15`). 
Such teams prefer a high tempo and frequently push the ball in transition to capitalize on early scoring opportunities.


2. Defensive-Oriented: 
The "Defensive-Oriented" style is characterized by a Defensive Rating (`DRTG`) below 105, paired with a defensive rebounding percentage (`DREB%`) above 75%. 
These teams focus on minimizing opponent scoring while controlling the defensive boards, emphasizing defensive stops as a core component of their success.


3. Three-Point Heavy: 
Teams classified as "Three-Point Heavy" attempt a large proportion of their shots from beyond the three-point arc (`FGA_3PT% > 0.4`). 
These teams emphasize spacing and rely heavily on three-point shooting as their primary offensive weapon, often using shooters to spread the defense.

4. Iso-Heavy: 
The "Iso-Heavy" play style relies on individual offensive creation. These teams have a high percentage of unassisted field goals made (`UAST_FGM% > 0.10`) while maintaining a relatively low assist rate (`AST% < 0.50`). 
This emphasizes isolation plays, where scoring often results from one-on-one matchups rather than intricate team play.


5. Big-Man Centric: 
Teams categorized as "Big-Man Centric" derive a significant portion of their points in the paint (`PAINT_PTS% > 0.50`) and have an offensive rebounding percentage greater than 30% (`OREB% > 0.30`). 
This strategy relies heavily on strong inside presence, favoring post-ups, putbacks, and exploiting mismatches near the basket.


6. Motion Offense: 
Teams employing "Motion Offense" have an assist rate (`AST%`) greater than 60%, emphasizing ball movement and off-ball player motion. 
Such teams prioritize finding the open man and creating quality scoring opportunities through high-paced passing and coordinated team dynamics.


7. Switch-Heavy Defense: 
The "Switch-Heavy Defense" style is identified when teams limit their opponents to an effective field goal percentage (`Opp_eFG%`) below 0.4. 
These teams employ frequent defensive switches, utilizing versatile defenders to disrupt opponents' offensive schemes and reduce their shooting efficiency.


8. Post-Up and Inside: 
Teams that significantly rely on scoring inside the paint (`PAINT_PTS% > 0.4`) are categorized as "Post-Up and Inside." 
This indicates a preference for post-up plays, using players skilled in finishing near the rim, often in a deliberate half-court setting.


9. Grit-and-Grind: 
The "Grit-and-Grind" label is applied to teams with a defensive rating below 110 (`DRTG < 110`) and an offensive rebounding rate greater than 30% (OREB% > 0.30). 
These teams are characterized by a physical style of play, emphasizing defensive toughness, securing rebounds, and generating second-chance opportunities through persistent effort.


10. Balanced/Adaptive: 
Teams that do not fit neatly into the above categories are considered "Balanced/Adaptive." 
Such teams vary their approach based on opponent weaknesses or game context, adapting to different situations with a mix of offensive and defensive tactics.


## Expected Outcomes

We expect to find patterns in which G-League teams closely mirror the playing styles of their NBA affiliates, particularly among organizations that stress continuity in player development, such as the Golden State Warriors and their G-League counterpart, the Santa Cruz Warriors. 
On the other hand, teams whose affiliates are managed with a different emphasis on coaching philosophies might display more diverse play styles between the NBA and G-League.

## Significance

The results of this study will provide insights into the role of stylistic alignment in player growth, team synergy, and organizational efficiency. 
Drawing from previous research on organizational alignment (e.g., Foster et al., 2016) and player development pipelines (e.g., Henderson et al., 2019), this study highlights how strategic consistency in playing styles could offer competitive advantages. 
The alignment between NBA and G-League affiliates is particularly important in enhancing player readiness for higher levels of competition and ensuring smooth transitions between the two leagues. 
Additionally, it supports the development of a shared basketball identity, which can improve overall team performance and cohesion.

## Citations

1. Foster, B., Smith, J., & Williams, R. (2016). *Organizational Alignment in Professional Sports: Impact on Talent Development and Team Performance*. Journal of Sports Analytics, 3(2), 120–135.

2. Henderson, T., Brown, L., & Johnson, P. (2019). *Development Leagues in Professional Sports: Assessing the Transition from Minor to Major Leagues*. Sports Science Review, 8(1), 45–60.

3. Oliver, D. (2004). *Basketball on Paper: Rules and Tools for Performance Analysis*. Brassey’s Sports.


