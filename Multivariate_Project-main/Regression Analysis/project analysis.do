clear
import delimited "new_clean.csv"

**data cleaning
gen hours = 0
replace hours = 1 if hours_use == "0-2"
replace hours = 3.5 if hours_use == "3-4"
replace hours = 5.5 if hours_use == "5-6"
replace hours = 7.5 if hours_use == "7-8"
replace hours = 10 if hours_use == "9+"

gen age_num = 0
replace age_num = 21 if age == "18-24"
replace age_num = 30 if age == "25-34"
replace age_num = 40 if age == "35-44"
replace age_num = 50 if age == "45-54"
replace age_num = 60 if age == "55-64"
replace age_num = 70 if age == "65+"

gen influence_better = 0
replace influence_better = 1 if sm_influence == "Influenced_better"
gen better_hours = influence_better*hours

gen influence_worse = 0
replace influence_worse = 1 if sm_influence == "Influenced_worse"
gen worse_hours = influence_worse*hours

gen influence_no = 0
replace influence_no = 1 if sm_influence == "No_influence"
gen no_hours = influence_no*hours

encode continent, generate(continent_cat)
encode trust_most, generate(trust)
encode ses, generate(ses_cat)
encode highest_education, generate(educ)
encode social_media_used_most, generate(media)
encode gender, generate(gender_cat)


** influence model
est clear
eststo: reg score_sum hours influence_better influence_worse better_hours worse_hours
eststo: reg score_sum hours influence_better influence_worse better_hours worse_hours i.media
eststo: reg score_sum hours influence_better influence_worse better_hours worse_hours i.media i.gender_cat i.educ i.ses_cat age_num
esttab using influence_model.csv, se ar2 replace label nonumber title("Perception of social media influence moderates the effect of social media use on vaccine knowledge") mtitle("Effect Model" "Social Media Control" "Demographic Controls") coeflabel(hours "Hours on Social Media" influence_better "Bias Perception: Better" influence_worse "Bias Perception: Worse" better_hours "Bias Perception: Better*Hours" worse_hours "Bias Perception: Worse*Hours" _cons "Constant") note("Note: Participants who have not seen any post related to vaccine usage are excluded from the regressions. Bias Perception dummies encode participant's subject perception of whether their judgement about vaccine is positively or negatively biased by social media posts. No bias perception is excluded as baseline group. Social media dummies encode participants' favorate social media. Facebook is excluded as the baseline most preferred social media.")

** trust model
est clear
eststo: reg score_sum hours i.trust
eststo: reg score_sum hours i.trust i.media
eststo: reg score_sum hours i.trust i.media i.gender_cat i.educ i.ses_cat age_num
esttab using trust_model.csv, se ar2 replace label nonumber title("Trust in instituition influences vaccine knolwdedge") mtitle("Effect Model" "Social Media Control" "Demographic Controls") coeflabel(hours "Hours on Social Media" _cons "Constant") note("Note: Dummy encoding for Doctors as the most trust-worthy source of information is excluded from the model as baseline group. Social media dummies encode participants' favorite social media. Facebook is excluded as the baseline most preferred social media.")


** generate graphs
gen influnce_level = 0
replace influnce_level = 1 if influence_better == 1
replace influnce_level = 2 if influence_worse == 1

twoway lfit score_sum hours
twoway (lfit score_sum hours if influence_better == 1) (lfit score_sum hours if influence_worse == 1) (lfit score_sum hours if influence_no == 1)

**useless codes
gen female = 1 if gender == "Female"
replace female = 0 if female == .
gen male = 1 if gender == "Male"
replace male = 0 if male == .

gen bachelor = 1 if highest_education == "Bachelor_Degree"
replace bachelor = 0 if bachelor == .
gen elementary = 1 if highest_education == "Elementary_or_less"
replace elementary = 0 if elementary == .
gen high_school = 1 if highest_education == "High_school"
replace high_school = 0 if high_school == .
gen master = 1 if highest_education == "Master_Degree"
replace master = 0 if master == .
gen professional = 1 if highest_education == "Professional_Degree"
replace professional = 0 if professional == .

gen middle_class =  1 if ses == "Middle Class"
replace middle_class = 0 if middle_class == .
gen upper_class =1 if ses == "Upper Class"
replace upper_class = 0 if upper_class == .

gen instagram = 0
replace instagram = 1 if social_media_used_most == "Instagram"

gen twitter = 0
replace twitter = 1 if social_media_used_most == "Twitter"

gen facebook = 0
replace facebook = 1 if social_media_used_most == "Facebook"

gen twitter_hours = twitter*hours
gen ins_hours = instagram*hours

gen influence = 0
replace influence = 1 if sm_influence == "Influenced_better" | sm_influence == "Influenced_worse"
drop if sm_influence == "Not_seen"
gen hours_influence = hours*influence



