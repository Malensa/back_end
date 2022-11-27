import requests
from bs4 import BeautifulSoup
from sklearn.metrics.pairwise import cosine_similarity
from sentence_transformers import SentenceTransformer
import pandas as pd
from heapq import nlargest
from flask import Flask

app = Flask(__name__)

@app.route('/get_recommendation', methods=['GET'])
def get_recommendation(url):
    reqs = requests.get(url)
    recipes = pd.read_pickle('recipes.pkl')
    soup = BeautifulSoup(reqs.text, 'html.parser')
    title = soup.title.contents
    title = title[0].split()
    title = ' '.join(title[:-3]).lower()
    #NLP part
    similarity_table = []
    urls_to_give = []
    model = SentenceTransformer('bert-base-nli-mean-tokens')
    similarity_rates = []
    sen_embeddings = model.encode(title)
    for _, row in recipes.iterrows():
        similarity = cosine_similarity(sen_embeddings.flatten().reshape(1, -1), row['vector'].flatten().reshape(1, -1))[0][0]
        if similarity == 1:
            continue
        else:
            similarity_rates.append({"recipe": row['recipe'], "similarity": similarity, "id": row['id']})
            #similarity_table.append({"title": title, "recipe": row['recipe'], "similarity": similarity, "id": row['id']})
    recommendations = nlargest(5, similarity_rates, key=lambda item: item["similarity"])
    for i in recommendations:
        urls_to_give.append([i['recipe'], "https://www.food.com/recipe/" + i["recipe"].replace(" ", "-") + "-" + i["id"], "the score"])
    return urls_to_give

if __name__ == '__main__':
    app.run(host='35.228.124.55', port=8080, debug=True)

print(get_recommendation('https://www.food.com/recipe/easy-lentil-stew-191459'))
