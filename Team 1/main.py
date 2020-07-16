import pandas as pd

columns = [
    "Total Theft Person Offs",
    "Total Criminal Damage Offs",
    "Total Burglary Offs",
    "TNO Offs",
    "Theft Taking of MV Offs",
    "Theft from Shops Offs",
    "Theft from MV Offs",
    "Personal Property Offs",
    "Non Domestic Abuse VWI Offs",
    "Harassment Offs",
    "Common Assault Offs",
    "ASB Calls",
]

crime_mapping = {
    "Total Theft Person Offs": [
        "Theft from MV Offs",
        "Theft or Taking of MV Offs",
        "16 Theft Offs",
    ],
    "Total Criminal Damage Offs": [
        "17 Arson and Criminal Damage Offs"
    ],
    "Total Burglary Offs":[
        "14 Burglary Offs",
    ],
    "TNO Offs": [
        "TNO Offs",
    ],
    "Theft Taking of MV Offs": [
        "Theft or Taking of MV Offs",
    ],
    "Theft from Shops Offs": [
        "Shoplifting Offs",
    ],
    "Theft from MV Offs": [
        "Theft from MV Offs",
    ],
    "Personal Property Offs": [
        "Robbery of Personal Property Offs",
        "Theft from Person Offs",
        "Theft Person Mobile Phone Off",
    ],
    # should contain other violences, for example "Violence with Injury Offs", as well, but do not have clear clue about how many of them are deomestic and how many are non domestic
    "Non Domestic Abuse VWI Offs": [
        "16 Theft Offs",
        "14 Burglary Offs",
        "13 Robbery Offs",
    ],
    "Harassment Offs": [
        "12 Sexual Offences Offs",
    ],
    # https://en.wikipedia.org/wiki/Common_assault
    "Common Assault Offs": [
        "Violence with Injury Offs",
        "Violence without Injury Offs",
    ],
    "ASB Calls": [
        "11 Violence Against the Person Offs",
        "17 Arson and Criminal Damage Offs"
    ],
}

years = ['14','15','16','17','18','19']

def main():
    crime_data = pd.read_csv('./crime_data.csv')
    boroughs = crime_data['OCU Name'].unique()

    crime_data_list = []

    for borough in boroughs:
        for year in years:
            yearly_data = crime_data[(crime_data["OCU Name"] == borough) & crime_data["Month-Year"].str.contains(year)]

            # count all kinds of crimes by year
            yearly_sum = yearly_data.sum(axis = 0)

            # generate new row with columns accroding to crime priorities
            crime_sum = {}
            crime_sum["Borough"] = borough
            crime_sum["Year"] = year
            for key in crime_mapping:
                crime_sum[key] = yearly_sum[crime_mapping[key]].sum()

            crime_data_list.append(crime_sum)
    
    df = pd.DataFrame(crime_data_list)
    df.to_csv('./general_crime_data.csv', index=True)         

if __name__ == "__main__":
    main()