from flask import Blueprint, jsonify

from project.api.utils import authenticate


scores_blueprint = Blueprint('scores', __name__)


@scores_blueprint.route('/scores/ping', methods=['GET'])
def ping_pong():
    return jsonify({
        'status': 'success',
        'message': 'pong!'
    })
